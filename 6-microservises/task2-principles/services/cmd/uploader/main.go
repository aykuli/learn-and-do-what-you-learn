package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"image"
	_ "image/gif" // Поддержка декодирования GIF
	"image/jpeg"
	"image/png"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	"github.com/nfnt/resize"
)

var minioClient *minio.Client
var bucketName string
var securityServiceURL string

// Структура ответа от сервиса security при валидации токена
type TokenValidationResponse struct {
	Valid    bool   `json:"valid"`
	UserID   int    `json:"user_id"`
	Username string `json:"username"`
	Error    string `json:"error"`
}

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("Предупреждение: .env файл не найден, используются системные переменные")
	}

	// Инициализация MinIO
	endpoint := os.Getenv("MINIO_ENDPOINT")
	accessKey := os.Getenv("MINIO_ROOT_USER")
	secretKey := os.Getenv("MINIO_ROOT_PASSWORD")
	bucketName = os.Getenv("MINIO_BUCKET_NAME")
	useSSL := os.Getenv("MINIO_USE_SSL") == "true"
	securityServiceURL = os.Getenv("SECURITY_SERVICE_URL")

	if endpoint == "" || accessKey == "" || secretKey == "" || bucketName == "" {
		log.Fatal("Критическая ошибка: Не все переменные окружения для MinIO заданы")
	}

	var err error
	minioClient, err = minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKey, secretKey, ""),
		Secure: useSSL,
	})
	if err != nil {
		log.Fatalf("Ошибка инициализации клиента MinIO: %v", err)
	}

	// Автоматически создаем бакет, если его нет
	ctx := context.Background()
	exists, err := minioClient.BucketExists(ctx, bucketName)
	if err != nil {
		log.Fatalf("Ошибка проверки бакета: %v", err)
	}
	if !exists {
		err = minioClient.MakeBucket(ctx, bucketName, minio.MakeBucketOptions{})
		if err != nil {
			log.Fatalf("Ошибка создания бакета: %v", err)
		}
		log.Printf("Бакет '%s' успешно создан", bucketName)
	}

	// Настройка Gin роутера
	r := gin.Default()
	// Ограничение на размер тела запроса (например, 20 МБ)
	r.MaxMultipartMemory = 20 << 20

	v1 := r.Group("/v1")
	{
		v1.POST("/upload", uploadFile)
		v1.GET("/user/:image", getUserImage)
	}

	port := os.Getenv("UPLOADER_PORT")
	if port == "" {
		port = "8081"
	}

	log.Printf("Сервис uploader запущен на порту %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Ошибка запуска сервера: %v", err)
	}
}

func verifyTokenWithSecurity(authHeader string) (*TokenValidationResponse, error) {
	validationURL := fmt.Sprintf("%s/v1/token/validation", securityServiceURL)
	req, err := http.NewRequest("GET", validationURL, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", authHeader)

	client := &http.Client{Timeout: 5 * time.Second}

	resp, err := client.Do(req)
	if err != nil {
		fmt.Println(err)

		return nil, fmt.Errorf("сервис авторизации недоступен")
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("токен невалиден")
	}

	var tokenInfo TokenValidationResponse
	if err := json.NewDecoder(resp.Body).Decode(&tokenInfo); err != nil || !tokenInfo.Valid {
		return nil, fmt.Errorf("ошибка валидации данных токена")
	}

	return &tokenInfo, nil
}

// POST /v1/upload — Обработчик загрузки файла
func uploadFile(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing Authorization header"})
		return
	}

	userInfo, err := verifyTokenWithSecurity(authHeader)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	// Получаем файл из Form Data (ключ "file")
	fileHeader, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Файл не найден в запросе (используйте ключ 'file')"})
		return
	}

	// Открываем файл для чтения
	file, err := fileHeader.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Не удалось открыть файл"})
		return
	}
	defer file.Close()

	// Генерируем уникальное имя файла для MinIO, чтобы избежать перезаписи
	ext := strings.ToLower(filepath.Ext(fileHeader.Filename))
	uniqueName := fmt.Sprintf("user_%s_%d_%s", userInfo.Username, time.Now().UnixNano(), fileHeader.Filename)

	var uploadBuffer io.Reader
	var uploadSize int64
	contentType := fileHeader.Header.Get("Content-Type")

	// Проверяем, является ли файл изображением (JPEG или PNG)
	if ext == ".jpg" || ext == ".jpeg" || ext == ".png" {
		// Сжимаем картинку
		compressedBytes, err := compressImage(file, ext)
		if err != nil {
			// Если сжатие не удалось, логируем и пытаемся загрузить оригинал
			log.Printf("Не удалось сжать картинку %s, загружаем оригинал: %v", fileHeader.Filename, err)
			_, _ = file.Seek(0, io.SeekStart) // Сбрасываем указатель чтения в начало
			uploadBuffer = file
			uploadSize = fileHeader.Size
		} else {
			// Переключаем буфер на сжатые байты
			uploadBuffer = bytes.NewReader(compressedBytes)
			uploadSize = int64(len(compressedBytes))
			log.Printf("Файл %s успешно сжат. Размер: %d байт -> %d байт", fileHeader.Filename, fileHeader.Size, uploadSize)
		}
	} else {
		// Для всех остальных типов файлов (PDF, ZIP, DOCX и т.д.) просто прокидываем поток
		uploadBuffer = file
		uploadSize = fileHeader.Size
	}

	// Загружаем файл в хранилище MinIO
	ctx := context.Background()
	_, err = minioClient.PutObject(ctx, bucketName, uniqueName, uploadBuffer, uploadSize, minio.PutObjectOptions{
		ContentType: contentType,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка загрузки файла в хранилище MinIO: " + err.Error()})
		return
	}

	// Возвращаем клиенту успешный ответ и путь к файлу
	fileURL := fmt.Sprintf("/%s/%s", bucketName, uniqueName)
	c.JSON(http.StatusOK, gin.H{
		"message":   "Файл успешно загружен",
		"filename":  uniqueName,
		"url":       fileURL,
		"size_byte": uploadSize,
	})
}

// Вспомогательная функция для пропорционального сжатия картинок
func compressImage(file io.Reader, ext string) ([]byte, error) {
	// Декодируем изображение в стандартный объект image.Image
	img, _, err := image.Decode(file)
	if err != nil {
		return nil, err
	}

	// Задаем максимальную ширину для сжатого изображения (например, 1200px)
	// Высота 0 означает, что библиотека resize сохранит оригинальные пропорции
	maxWidth := uint(1200)

	// Если оригинальная картинка меньше maxWidth, оставляем ее ширину
	if uint(img.Bounds().Dx()) < maxWidth {
		maxWidth = uint(img.Bounds().Dx())
	}

	// Сжимаем с использованием качественного интерполяционного алгоритма Lanczos3
	resizedImg := resize.Resize(maxWidth, 0, img, resize.Lanczos3)

	// Записываем результат в буфер байт
	var buf bytes.Buffer
	if ext == ".png" {
		// Для PNG используем стандартное сжатие (можно настроить Encoder)
		err = png.Encode(&buf, resizedImg)
	} else {
		// Для JPEG выставляем качество (Quality) на уровне 80% (оптимально для веба)
		err = jpeg.Encode(&buf, resizedImg, &jpeg.Options{Quality: 80})
	}

	if err != nil {
		return nil, err
	}

	return buf.Bytes(), nil
}

// GET /v1/user/{image} — Проверка токена через security и отдача картинки из MinIO
func getUserImage(c *gin.Context) {
	imageName := c.Param("image")
	if imageName == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Имя файла не указано"})
		return
	}

	// 1. Берем токен из входящего заголовка Authorization
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Отсутствует заголовок Authorization"})
		return
	}

	userInfo, err := verifyTokenWithSecurity(authHeader)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	// ACL Ownership Enforcement: The filename must start with "user_bob_"
	expectedPrefix := fmt.Sprintf("user_%s_", userInfo.Username)
	if !strings.HasPrefix(imageName, expectedPrefix) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access Denied: You do not own this image resource"})
		return
	}

	// 3. Запрос файла из MinIO (GET /images/{image})
	ctx := context.Background()
	object, err := minioClient.GetObject(ctx, bucketName, imageName, minio.GetObjectOptions{})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка при обращении к хранилищу MinIO"})
		return
	}
	defer object.Close()

	objInfo, err := object.Stat()
	if err != nil {
		if minio.ToErrorResponse(err).Code == "NoSuchKey" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Изображение не найдено в хранилище"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка получения данных о файле"})
		return
	}

	// 4. Стримим файл напрямую клиенту
	c.Header("Content-Type", objInfo.ContentType)
	c.Header("Content-Length", fmt.Sprintf("%d", objInfo.Size))

	if _, err := io.Copy(c.Writer, object); err != nil {
		log.Printf("Ошибка стриминга файла: %v", err)
	}
}

// 1. Загрузка картинки (будет автоматически сжата):
// curl -X POST http://localhost:8081/v1/upload \
//   -F "file=@/path/to/your/photo.jpg"
// -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6Iml2YW4iLCJleHAiOjE3ODU1MjUyMTIsImlhdCI6MTc4NTUxODAxMn0.Q-WvE4-ORY8CMQvecPZTWfuUC7V4DN8RgCnI3JMHOIQ"
// 2. Загрузка любого другого документа (загрузится «как есть»):bashcurl -X POST http://localhost:8081/v1/upload \
//   -F "file=@/path/to/document.pdf"
