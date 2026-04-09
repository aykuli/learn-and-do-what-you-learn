#!/bin/bash

# 1. Определяю нужные переменные
DOCKER_BIN="/usr/bin/docker"
NETWORK_NAME='web-py-app_backend'
DEST_DIR='/opt/backup'
BACKUP_HOST='db'
DB_USER='root'

TARGET_DIR="/opt/web-py-app"

# 2. Перехожу в папку проекта, где лежит .env файл
cd $TARGET_DIR || exit 1

# 3.Загружу переменные из .env файла
set -a
. "${TARGET_DIR}/.env"
set +a

if [ -f "${DEST_DIR}/dump.sql" ]; then
  if [ -f "${DEST_DIR}/dump.sql.old" ]; then
      rm "${DEST_DIR}/dump.sql.old"
  fi
  mv "${DEST_DIR}/dump.sql" "${DEST_DIR}/dump.sql.old"
fi

echo "$(date): Начало резервного копирования..."

# note schnitzler/mysqldump образ использует MariaDB. С MySQL 8.0+, аутентификация по умолчанию -  caching_sha2_password.
# Базовый MariaDB клиент в schnitzler/mysqldump не включает в себя специфический файл для включения этой функциональности. 
# mariadb-connector-c добавляет этот файл.
$DOCKER_BIN run --rm   --entrypoint "/bin/sh" -v "${DEST_DIR}":/backup --network="${NETWORK_NAME}" schnitzler/mysqldump:3.18 -c "apk add --no-cache mariadb-connector-c && mysqldump -h "${BACKUP_HOST}" -u "${DB_USER}" -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" > /backup/dump.sql"

# 3. Радуюсь полученному результату:
if [ $? -eq 0 ]; then
  echo "$(date): Завершено успешно!"
  echo '---------------------'
  echo 'Результирующие файлы:'
  ls -al ${DEST_DIR}
else
    echo "$(date): ОШИБКА!"
fi

echo "--------------------------------------"
