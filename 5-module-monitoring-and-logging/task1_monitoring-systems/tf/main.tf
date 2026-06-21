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

data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "teamcity-server" {
  name               = "teamcity-server"
  hostname           = "teamcity-server"
  folder_id          = var.folder_id
  service_account_id = var.service_account_id
  platform_id        = "standard-v3"
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
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
resource "yandex_compute_instance" "teamcity-agent" {
  name               = "teamcity-agent"
  hostname           = "teamcity-agent"
  folder_id          = var.folder_id
  service_account_id = var.service_account_id
  platform_id        = "standard-v3"
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data  = templatefile("${path.module}/agent-cloud-init.tftpl", {
      ssh_keys = var.ssh_key,
      vm_user  = var.vm_user
      server_ip = yandex_compute_instance.teamcity-server.network_interface.0.nat_ip_address
    })
  }
}


resource "yandex_compute_instance" "nexus" {
  name = "nexus"
  hostname = "nexus"
  folder_id = var.folder_id
  service_account_id = var.service_account_id
  platform_id = "standard-v3"
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_key}"
  }
}

output "nexus-ip" {
  value = yandex_compute_instance.nexus.network_interface.0.nat_ip_address
  }
output "teamcity-agent-ip" {
  value = yandex_compute_instance.teamcity-agent.network_interface.0.nat_ip_address
  }
output "teamcity-server-ip" {
  value = yandex_compute_instance.teamcity-server.network_interface.0.nat_ip_address
  }