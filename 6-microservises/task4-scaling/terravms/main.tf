terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=1.12.0"
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
  service_account_key_file = file("authorized_key.json")
}

# 1. Создаем виртуальную сеть (VPC)
resource "yandex_vpc_network" "redis_network" {
  name = "redis-cluster-network"
}

# 2. Создаем подсети в трех разных зонах доступности (дата-центрах)
resource "yandex_vpc_subnet" "subnet_a" {
  name           = "redis-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.redis_network.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet_b" {
  name           = "redis-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.redis_network.id
  v4_cidr_blocks = ["10.2.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet_d" {
  name           = "redis-subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.redis_network.id
  v4_cidr_blocks = ["10.3.0.0/24"]
}

# 3. Разворачиваем Шардированный Кластер Redis
resource "yandex_mdb_redis_cluster" "my_redis_cluster" {
  name        = "my-sharded-redis-cluster"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.redis_network.id
  sharded     = true # ВКЛЮЧАЕТ ШАРДИРОВАНИЕ

  config {
    password = "SuperSecretPassword123!" # Замените на надежный пароль
    version  = "7.2-valkey"                      # Версия Redis
  }

  resources {
    resource_preset_id = "hm3-c2-m8" # Тип памяти и CPU (минимальный для Production)
    disk_size          = 16           # Размер диска в ГБ
    disk_type_id       = "network-ssd"
  }

  # --- ШАРД 1 ---
  # Мастер в зоне A
  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.subnet_a.id
    shard_name = "shard1"
  }
  # Реплика в зоне B
  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.subnet_b.id
    shard_name = "shard1"
  }

  # --- ШАРД 2 ---
  # Мастер в зоне B
  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.subnet_b.id
    shard_name = "shard2"
  }
  # Реплика в зоне C
  host {
    zone      = "ru-central1-d"
    subnet_id = yandex_vpc_subnet.subnet_d.id
    shard_name = "shard2"
  }

  # --- ШАРД 3 ---
  # Мастер в зоне C
  host {
    zone      = "ru-central1-d"
    subnet_id = yandex_vpc_subnet.subnet_d.id
    shard_name = "shard3"
  }
  # Реплика в зоне A
  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.subnet_a.id
    shard_name = "shard3"
  }
}
