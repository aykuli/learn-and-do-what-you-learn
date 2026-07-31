package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"task3/internal/postgres"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"golang.org/x/crypto/bcrypt"

	"github.com/golang-jwt/jwt/v5"
)

var jwtSecret []byte

// DTO структуры для запросов и ответов
type UserRegisterReq struct {
	Username string `json:"username" binding:"required,min=3,max=50"`
	Password string `json:"password" binding:"required,min=6"`
}

type UserLoginReq struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type UserResponse struct {
	ID        int       `json:"id"`
	Username  string    `json:"username"`
	CreatedAt time.Time `json:"created_at"`
}

// JWT Claims структура
type Claims struct {
	UserID   int    `json:"user_id"`
	Username string `json:"username"`
	jwt.RegisteredClaims
}

func main() {
	_ = godotenv.Load()
	dsn := os.Getenv("POSTGRES_DSN")

	if dsn == "" {
		log.Fatal("Критическая ошибка: Переменная POSTGRES_DSN не задана в окружении")
	}
	secretStr := os.Getenv("JWT_SECRET")
	if secretStr == "" {
		secretStr = "default_fallback_secret_key"
	}
	jwtSecret = []byte(secretStr)

	storage, err := postgres.NewStorage(dsn)
	if err != nil {
		log.Fatal(err)
	}
	ctx := context.Background()
	if err = storage.Ping(ctx); err != nil {
		log.Printf("[POSTGRES] Ping err: %v", err)
	}
	// Настройка роутера Gin
	r := gin.Default()

	// Эндпоинты
	v1 := r.Group("/v1")
	{
		v1.POST("/user", registerUser(storage, ctx))
		v1.GET("/user", getUserInfo(storage, ctx))
		v1.POST("/token", loginUser(storage, ctx))
		v1.GET("/token/validation", validateToken)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Сервис запущен на порту %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Ошибка запуска сервера: %v", err)
	}
}

// === ОБРАБОТЧИКИ (HANDLERS) ===

// POST /v1/user - Регистрация пользователя
func registerUser(storage *postgres.DBStorage, ctx context.Context) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req UserRegisterReq
		if err := c.ShouldBindJSON(&req); err != nil {
			fmt.Println(req)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных: " + err.Error()})
			return
		}

		// Хешируем пароль
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка шифрования пароля"})
			return
		}

		err = storage.SaveUser(ctx, req.Username, string(hashedPassword))
		if err != nil {
			// Проверяем на дубликат username (код ошибки Postgres 23505)
			if strings.Contains(err.Error(), "duplicate key") {
				c.JSON(http.StatusConflict, gin.H{"error": "Пользователь с таким именем уже существует"})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка сохранения в БД: " + err.Error()})
			return
		}

		c.JSON(http.StatusCreated, gin.H{"message": "Пользователь успешно зарегистрирован"})
	}
}

// POST /v1/token - Логин пользователя (Выдача токена)
func loginUser(storage *postgres.DBStorage, ctx context.Context) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req UserLoginReq
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
			return
		}

		// Ищем пользователя в БД
		id, passwordHash, err := storage.GetPasswordHash(ctx, req.Username)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Неверное имя пользователя или пароль"})
			return
		}

		// Проверяем пароль
		if err := bcrypt.CompareHashAndPassword([]byte(passwordHash), []byte(req.Password)); err != nil {
			fmt.Println(err)
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Неверное имя пользователя или пароль"})
			return
		}

		// Генерируем JWT токен (время жизни 2 часа)
		expirationTime := time.Now().Add(2 * time.Hour)
		claims := &Claims{
			UserID:   id,
			Username: req.Username,
			RegisteredClaims: jwt.RegisteredClaims{
				ExpiresAt: jwt.NewNumericDate(expirationTime),
				IssuedAt:  jwt.NewNumericDate(time.Now()),
			},
		}

		token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
		tokenString, err := token.SignedString(jwtSecret)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка генерации токена"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"token":      tokenString,
			"expires_at": expirationTime.Format(time.RFC3339),
		})
	}
}

// GET /v1/token/validation - Проверка валидности токена
func validateToken(c *gin.Context) {
	tokenStr, err := extractToken(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	claims := &Claims{}
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("неожиданный метод подписи: %v", token.Header["alg"])
		}
		return jwtSecret, nil
	})

	if err != nil || !token.Valid {
		c.JSON(http.StatusUnauthorized, gin.H{"valid": false, "error": "Токен невалиден или просрочен"})
		return
	}

	// Возвращаем данные из токена, чтобы шлюз API или другие сервисы знали, кто делает запрос
	c.JSON(http.StatusOK, gin.H{
		"valid":      true,
		"user_id":    claims.UserID,
		"username":   claims.Username,
		"expires_at": claims.ExpiresAt,
	})
}

// GET /v1/user - Получение информации о текущем пользователе (защищенный эндпоинт)
func getUserInfo(storage *postgres.DBStorage, ctx context.Context) gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenStr, err := extractToken(c)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
			return
		}

		claims := &Claims{}
		token, err := jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
			return jwtSecret, nil
		})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Требуется авторизация"})
			return
		}

		// Получаем свежие данные из базы по ID из токена
		username, createdAt, err := storage.GetUserInfo(ctx, claims.UserID)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Пользователь не найден"})
			return
		}

		c.JSON(http.StatusOK, UserResponse{
			ID:        claims.UserID,
			Username:  username,
			CreatedAt: createdAt,
		})
	}
}

// Вспомогательная функция для извлечения токена из заголовка Authorization
func extractToken(c *gin.Context) (string, error) {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		return "", errors.New("отсутствует заголовок Authorization")
	}

	parts := strings.Split(authHeader, " ")
	if len(parts) != 2 || parts[0] != "Bearer" {
		return "", errors.New("неверный формат заголовка Authorization (ожидается 'Bearer <token>')")
	}

	return parts[1], nil
}

// Регистрация пользователя:
// curl -X POST http://localhost:8080/v1/user \
//   -H "Content-Type: application/json" \
//   -d '{"username": "ivan", "password": "securepassword123"}'
// Логин (Получение токена):
// curl -X POST http://localhost:8080/v1/token \
//   -H "Content-Type: application/json" \
//   -d '{"username": "ivan", "password": "securepassword123"}'
// Скопируйте полученную строку token из ответа.Проверка (Валидация) токена:
// curl -X GET http://localhost:8080/v1/token/validation \
//   -H "Authorization: Bearer <ВСТАВЬТЕ_ТОКЕН_СЮДА>"
// Получение профиля пользователя:
// curl -X GET http://localhost:8080/v1/user \
//   -H "Authorization: Bearer <ВСТАВЬТЕ_ТОКЕН_СЮДА>"

