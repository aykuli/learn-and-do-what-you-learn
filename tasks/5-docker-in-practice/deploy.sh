#!/bin/bash

# Прекращаю выполнение при любой ошибке
set -e

REPO_URL="https://github.com/aykuli/shvirtd-example-python.git"
TARGET_DIR="/opt/web-py-app"

echo "1. Клонирование репозитория в $TARGET_DIR ---"

# Проверяю, существует ли папка. Если да — удаляю, чтобы скачать свежую версию
if [ -d "$TARGET_DIR" ]; then
    echo "Папка $TARGET_DIR уже существует. Обновляю содержимое..."
    sudo rm -rf "$TARGET_DIR"
fi

git clone $REPO_URL $TARGET_DIR

echo "2. Запуск Docker Compose ---"

# Переходим в папку проекта
cd $TARGET_DIR

# Запускаем сборку и контейнеры в фоновом режиме
docker compose up -d

echo "3. Проверка запущенных контейнеров ---"
docker compose ps
