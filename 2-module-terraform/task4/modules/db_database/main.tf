terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
  }
  required_version = ">=1.12.0"
}

# Подключитесь к БД
# https://yandex.cloud/ru/docs/managed-mysql/quickstart#linux-macos_1

resource "yandex_mdb_mysql_database_v2" "db" {
  cluster_id = var.cluster_id
  name       = var.db_name

  deletion_protection_mode = var.deletion_protection_mode
}

resource "yandex_mdb_mysql_user" "user" {
  cluster_id = var.cluster_id
  name       = var.username
  password   = var.password

  permission {
    database_name = yandex_mdb_mysql_database_v2.db.name
    roles         = ["ALL"]
  }

  global_permissions = ["PROCESS"]

  authentication_plugin = var.auth_plugin
}

