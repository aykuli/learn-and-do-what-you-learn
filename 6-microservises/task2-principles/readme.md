# [Домашнее задание к занятию «Микросервисы: принципы»](https://github.com/netology-code/micros-homeworks/blob/main/11-microservices-02-principles.md)

## Задача 1: API Gateway
<details>
<summary>текст задачи
</summary>
Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:

* маршрутизация запросов к нужному сервису на основе конфигурации,
* возможность проверки аутентификационной информации в запросах,
* обеспечение терминации HTTPS.

Обоснуйте свой выбор.
</details>

В своей практике я работала реализацию API Gateway через Nginx. Пример:

```
location /backend/api/v1/ {
        proxy_pass http://service1:port1/api/v1/some/endpoint;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    location /another_endpoint {
        proxy_pass http://service2:port2;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /another_one_endpoint {
        proxy_pass http://service3:port3/api/v2;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
```

Сравню с другими существующими решениями:


| Инструмент | Маршрутизация по конфигурации | Проверка аутентификации | Терминация HTTPS | Особенности и среда применения |
| --- | --- | --- | --- | --- |
| KrakenD | Декларативная (один krakend.json), очень простая настройка. | Встроенный плагин JWT (валидация подписи, сроков и прав без кода). | Встроенная (поддерживает Let's Encrypt из коробки). | Сверхбыстрый (на Go), идеален для высокой производительности и фиксированных конфигов.|
| Kong (CE) | Динамическая (через YAML-файлы или REST API). | Множество бесплатных плагинов (JWT, API Keys, Basic Auth, OAuth2). | Полная поддержка TLS/SSL на базе OpenResty. | Самая богатая экосистема плагинов, легко расширять в будущем. |
| Nginx | Классическая (через блоки location в nginx.conf). | Через директиву auth_request (делегирует проверку вашему микросервису). | Эталонная, высокопроизводительная терминация. | Проверенный временем стандарт. | Требует сторонних модулей для сложной валидации JWT.| 
| Traefik | Автоматическая (на основе меток/лейблов в Docker/Kubernetes). | Через Middleware (плагин Forward Auth обращается к вашему сервису проверки). | Автоматическое управление сертификатами Let's Encrypt. | Лучший выбор, если вся ваша инфраструктура развернута в Docker или K8s. |
| Yandex API Gateway | По стандарту OpenAPI 3.0 (в YAML-интерфейсе облака). | Через интеграцию с Cloud Functions (кастомный Authorizer). | Автоматическая (интеграция с Certificate Manager). | Облачное Serverless-решение. | Платите только за фактическое количество запросов. |


Для выбора имхо недостаточно данных.
Если серевра арендованы в ЯО - Yandex API Gateway можно,
Если нужно быстро очень и нет Kubernetes - знакомый nginx,
если нужна максимальная скорост обработки HTTP запросов - KrakenD,
если хочется напрямую из шлюза отправлять сообщения в очереди - Kong.

## Задача 2: Брокер сообщений

<details>
<summary>текст задачи
</summary>
Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

Решение должно соответствовать следующим требованиям:

* поддержка кластеризации для обеспечения надёжности,
* хранение сообщений на диске в процессе доставки,
* высокая скорость работы,
* поддержка различных форматов сообщений,
* разделение прав доступа к различным потокам сообщений,
* простота эксплуатации.

Обоснуйте свой выбор.
</details>

| Критерий | RabbitMQ | Apache Kafka | ActiveMQ (Artemis) | NATS JetStream |
| --- | --- | --- | --- | --- |
| Кластеризация и надежность | Высокая. Родные кворумные очереди (Quorum Queues) на базе алгоритма Raft. | Отличная. Изначально распределенная система с репликацией логов. | Средняя. Кластеризация сложна в настройке (нужен shared storage или ZooKeeper-подобные реплики). | Отличная. Легковесный встроенный Raft-кластер. | 
| Хранение сообщений на диске | Да. Все сообщения могут хранится на диске. | Да. Логи сообщений пишутся на диск по умолчанию и хранятся долго. |  Да. Поддерживает высокопроизводительный KahaDB или JDBC. | Да. JetStream добавляет надежное дисковое хранилище к NATS. |
| Скорость работы | Высокая (десятки тыс. msg/sec). Низкая задержка (low latency). | Экстремальная (миллионы msg/sec) за счет последовательной записи на диск. | Средняя/Высокая (уступает Kafka и RabbitMQ под нагрузкой). | Экстремальная (миллионы msg/sec) с ультра-низкой задержкой. | 
| Форматы сообщений | Любые (Binary, JSON, XML, Protobuf). Сообщение — это массив байт. | Любые (обычно байты, есть интеграция со Schema Registry для Avro/JSON). | Любые (JMS Text, Object, Map, Bytes, Stream). | Любые (Сообщения передаются в виде байтовых массивов). |
| Разделение прав доступа (RBAC) | Отличное. Разграничение прав (Read/Write/Configure) на уровне виртуальных хостов (vhosts) и очередей/эксчейнджей. | Отличное. ACL на уровне топиков, групп потребителей и префиксов. | Хорошее. Ролевая модель на уровне очередей и адресов (JAAS). | Отличное. Изоляция на уровне аккаунтов и субъектов (NATS Accounts/JWT). | 
| Простота эксплуатации | Высокая. Готовый Web-интерфейс «из коробки», простая установка, понятная концепция AMQP. | Низкая. Сложная архитектура, требует глубокого тюнинга JVM, дисков и сетевых настроек. | Средняя. Требует управления сложной конфигурацией Java-приложения и XML. | Очень высокая. Один бинарный файл без зависимостей, но управление только через CLI/API. | 

Я бы выбрала rabbitMQ за его простоту и распространённость. Любой разработчик, пришедший на проект будет с ним знаком, имхо.


## Задача 3: API Gateway * (необязательная)

<details>
<summary>текст задачи
</summary>

### Есть три сервиса:

**minio**
- хранит загруженные файлы в бакете images,
- S3 протокол,

**uploader**
- принимает файл, если картинка сжимает и загружает его в minio,
- POST /v1/upload,

**security**
- регистрация пользователя POST /v1/user,
- получение информации о пользователе GET /v1/user,
- логин пользователя POST /v1/token,
- проверка токена GET /v1/token/validation.

### Необходимо воспользоваться любым балансировщиком и сделать API Gateway:

**POST /v1/register**
1. Анонимный доступ.
2. Запрос направляется в сервис security POST /v1/user.

**POST /v1/token**
1. Анонимный доступ.
2. Запрос направляется в сервис security POST /v1/token.

**GET /v1/user**
1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
2. Запрос направляется в сервис security GET /v1/user.

**POST /v1/upload**
1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
2. Запрос направляется в сервис uploader POST /v1/upload.

**GET /v1/user/{image}**
1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
2. Запрос направляется в сервис minio GET /images/{image}.

### Ожидаемый результат

Результатом выполнения задачи должен быть docker compose файл, запустив который можно локально выполнить следующие команды с успешным результатом.
Предполагается, что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки, который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.
Авторизация
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token

**Загрузка файла**

```
curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg http://localhost/upload
```

**Получение файла**

```
curl -X GET http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg
```
</details>


Получаемый [./compose.yml](./compose.yml):

```yaml
networks:
  fileservice:
    driver: bridge

volumes:
  minio-data:
  postgres-data:

services:
  minio:
    image: minio/minio:latest
    container_name: minio
    networks:
      - fileservice
    environment:
      MINIO_ROOT_USER: ${MINIO_ROOT_USER}
      MINIO_ROOT_PASSWORD: ${MINIO_ROOT_PASSWORD}
    ports:
      - 9000:9000 # S3-API
      - 9001:9001 # Console
    volumes:
      - minio-data:/data
    entrypoint: minio
    command: server --console-address ":9001" /data
    # The healthcheck guarantees that the MC container waits until MinIO is fully ready
    healthcheck:
      test: ["CMD", "mc", "ready", "local"]
      interval: 5s
      timeout: 5s
      retries: 5
  # This companion service auto-creates your bucket and then exits gracefully
  minio-create-bucket:
    image: minio/mc:latest
    container_name: minio_init
    depends_on:
      minio:
        condition: service_healthy
    networks:
      - fileservice
    entrypoint: >
      /bin/sh -c "
      mc alias set myminio http://minio:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD};
      if ! mc ls myminio/${MINIO_BUCKET_NAME} > /dev/null 2>&1; then
        mc mb myminio/${MINIO_BUCKET_NAME};
        echo 'Bucket created successfully.';
      else
        echo 'Bucket already exists. Skipping.';
      fi
      "

  postgres:
    image: postgres:17-alpine
    container_name: postgres
    networks:
      - fileservice
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-security_db}"]
      interval: 5s
      timeout: 5s
      retries: 5

  security:
    build: 
      context: ./services
      dockerfile: Dockerfile.security
    container_name: security
    networks:
      - fileservice
    ports:
      - "8080:8080"
    environment:
      - POSTGRES_DSN=${POSTGRES_DSN}
      - JWT_SECRET=${JWT_SECRET}
      - PORT=${PORT}
    depends_on:
      postgres:
        condition: service_healthy
  uploader:
    build:
      context: ./services
      dockerfile: Dockerfile.uploader
    container_name: uploader
    networks:
      - fileservice
    ports:
      - "8081:8081"
    environment:
      - MINIO_ENDPOINT=minio:9000
      - MINIO_ROOT_USER=${MINIO_ROOT_USER}
      - MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
      - MINIO_BUCKET_NAME=${MINIO_BUCKET_NAME}
      - MINIO_USE_SSL=${MINIO_USE_SSL}
      - SECURITY_SERVICE_URL=http://security:8080
      - UPLOADER_PORT=${UPLOADER_PORT}
    depends_on:
      minio:
        condition: service_healthy
      security:
        condition: service_started

  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - 80:80
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - fileservice
```

![](./assets/1.png)


Написала на Го 2 сервиса: [security](./services/cmd/security/main.go) & [uploader](./services/cmd/uploader/main.go). Лежат в папке [./services/cmd/](./services/cmd/).


Запросы работают:

![](./assets/0.png)
