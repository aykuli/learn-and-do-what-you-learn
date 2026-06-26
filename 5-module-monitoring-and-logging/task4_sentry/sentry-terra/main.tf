terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
  }
  required_version = ">=1.12.0"
}

provider "yandex" {
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  zone                     = var.default_zone
  service_account_key_file = file("authorized_key.json")
}

data "yandex_compute_image" "ubuntu2204" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "sentry-server" {
  name               = "sentry-server"
  hostname           = "sentry-server"
  folder_id          = var.folder_id
  service_account_id = var.service_account_id
  platform_id        = "standard-v3"
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu2204.id
      size     = 60
      type     = "network-ssd"
    }
  }
  network_interface {
    security_group_ids = [yandex_vpc_security_group.sentry.id]
    subnet_id = var.subnet_id
    nat       = true
  }

  resources {
    cores         = 4
    memory        = 32
    core_fraction = 100
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data  = templatefile("${path.module}/server-cloud-init.tftpl", {
      ssh_keys = var.ssh_key,
      vm_user  = var.vm_user
    })
  }
}

resource "yandex_vpc_security_group" "sentry" {
  name        = "sentry-sg"
  labels      = { project = "sentry" }

  network_id  = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "TCP 9000 for sentry"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9000
  }
  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
    description    = "Allow SSH"
  }
  ingress {
    protocol    = "TCP"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port        = 80
    description = "Allow HTTP"
  }

  ingress {
    protocol    = "TCP"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port        = 443
    description = "Allow HTTPS"
  }
  egress {
    protocol       = "ANY"
    description    = "Allow full outbound internet traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = -1
    to_port        = -1
  }
}

output "sentry-server-ip" {
  value = yandex_compute_instance.sentry-server.network_interface.0.nat_ip_address
}