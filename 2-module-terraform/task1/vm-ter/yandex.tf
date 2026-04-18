

# Создание облачной сети и подсетей
resource "yandex_vpc_network" "aynur-network" {
  name      = "aynur-network-from-terraform"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "aynur-subnet" {
  name           = "aynur-subnet-from-teraform"
  v4_cidr_blocks = ["10.130.10.0/24"]
  network_id     = yandex_vpc_network.aynur-network.id
  zone           = "ru-central1-d"
}

data "yandex_compute_image" "ubuntu_from_market" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "aynur_vm_from_terra_resource" {
  name = "aynur_vm_from_terra"
  platform_id = "standard-v3"

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_from_market.id
      size     = 10
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.aynur-subnet.id
    nat       = true
  }
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    user-data = templatefile("config.yml",{
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}