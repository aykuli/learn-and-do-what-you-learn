# Домашнее задание к занятию 5. «Практическое применение Docker»

## Задача 0

![Check if docker compose installed](./assets/0.png)

## Задача 1

[Dockerfile.python](https://github.com/aykuli/shvirtd-example-python/blob/main/Dockerfile.python)

```docker
# stage 1
FROM python:3.12-slim AS builder

#  Ваш код здесь #
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# stage 2
FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /install /usr/local

EXPOSE 5000

# Запускаем приложение с помощью uvicorn, делая его доступным по сети
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"] 
```
### Создание докер образа из файла Dockerfile.python

![docker build](./assets/1.png)

## Задача 2

![creatingg registry in yandex cloud and pulling image onto it](./assets/2.png)

Результат сканирования запуленного образа в консоли:

![scanning result](./assets/2-1.png)

Посмотреть в web ui yandex cloud:

![scanning result in web ui](./assets/2-2.png)

## Задача 3

1. Создание `compose.yml` файла

<details>
<summary>compose.yml</summary>

```yml

include:
  - proxy.yaml

services:
  web:
    image: cr.yandex/crpi5lfj1ah372dcbvrk/py-web-app:1.0.0
    build:
      context: .
      dockerfile: Dockerfile.python
    restart: always
    depends_on:
      - db
    ports:
      - 5000:5000
    environment:
      - DB_HOST=db
      - DB_USER=${MYSQL_USER}
      - DB_PASSWORD=${MYSQL_PASSWORD}
      - DB_NAME=${MYSQL_DATABASE}
    networks:
      backend:
        ipv4_address: 172.20.0.5

  db:
    image: mysql:8
    restart: always
    env_file:
      - .env
    networks:
      backend:
        ipv4_address: 172.20.0.10
```
</details>


`docker compose config`
![docker compose config](./assets/3.png)

2. Запуск сервисов

![running servises](./assets/3-1.png)

3. Подключение к локальной БД mysql

![local docker db container execing](./assets/3-2.png)

4. Остановка сервисов

![services stopping](./assets/3-4.png)


## Задача 4

1. Моя машинка

![vm](./assets/4-6.png)

2. Docker, git, compose на месте:

![libs](./assets/4-7.png)

Добавила адрес ВМ как разрешённый в test registry in yc:
![](./assets/4-1.png)

Пришлось делать ещё телодвижения, такие как:
* Docker compose всё никак не запускался. Оказалось root пользователь не знат про docker-compose плагин. Скопировала плагин от пользователя, под которым захожу в  `/usr/local/lib/`, и нанконец заработало.

```bash
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo cp ~/.docker/cli-plugins/docker-compose /usr/local/lib/docker/cli-plugins/
```

* Почему-то не с первого раза завелась бд. Со второго - да. Так и не поняла, в чём было дело.

3. bash-скрипт запуска приложения:

see [deploy.sh](./deploy.sh)

Запуск deploy.sh скрипта:
![](./assets/4-4.png)

4. Проверка http подключений к приложению через https://check-host.net/check-http

Куча запросов отовсюду - проверяю работу приложения и инфраструктуры:
![](./assets/4-2.png)

Записи об этом в бд в табличке:
![](./assets/4-3.png)

5. Docker remote ssh context

![Docker remote ssh context](./assets/4-5.png)

Можно даже внутрь контейнеров заходить н удлаённом сервере, так классно, эх кабы знать раньше:
![Docker remote ssh context](./assets/4-8.png)