# @note tutorial
# https://yandex.cloud/ru/docs/compute/tutorials/coi-with-terraform

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
  }
}

provider "yandex" {
  zone = "ru-central1-d"
  token = var.token
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}

# Создание сервисного аккаунта и назначение ему ролей
resource "yandex_iam_service_account" "aynur-admin" {
  name = "aynur-admin-service-account"
}

resource "yandex_resourcemanager_folder_iam_member" "admin" {
  folder_id = var.folder_id
  role   = "admin"
  member = "serviceAccount:${yandex_iam_service_account.aynur-admin.id}"
}

# Создание облачной сети и подсетей
resource "yandex_vpc_network" "aynur-network" {
  name = "aynur-network-from-terraform"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "aynur-subnet" {
  name = "aynur-subnet-from-teraform"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id = yandex_vpc_network.aynur-network.id
  zone = "ru-central1-d"
}

# Создание группы безопасности

resource "yandex_vpc_security_group" "sg-aynur" {
  name                = "security-group-aynur"
  network_id          = yandex_vpc_network.aynur-network.id
  egress {
    protocol          = "ANY"
    description       = "any"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
  ingress {
    protocol          = "TCP"
    description       = "ext-http"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    port              = 80
  }
  ingress {
    protocol          = "TCP"
    description       = "healthchecks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 80
  }
}

data "yandex_compute_image" "ubuntu_from_market" {
  image_id = "fd8498pb5smsd5ch4gid"
}

resource "yandex_compute_instance" "aynur_vm_from_terra_resource" {
  name = "aynur_vm_from_terra"
  platform_id = "standard-v3"

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_from_market.id
      size = 10
      type = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.aynur-subnet.id
    nat = true
    security_group_ids = [ yandex_vpc_security_group.sg-aynur.id ]
  }
  resources {
    cores = 2
    memory = 1
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    enable-oslogin = false
    user-data = templatefile("config.yml",{
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
  }

}

output "external_ip" {
  value = yandex_compute_instance.aynur_vm_from_terra_resource.network_interface.0.nat_ip_address
}