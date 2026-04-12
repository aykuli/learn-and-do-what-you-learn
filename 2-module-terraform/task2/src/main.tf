resource "yandex_vpc_network" "develop" {
  folder_id = var.folder_id
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_instance.image_family
}
resource "yandex_compute_instance" "platform" {
  name            = var.vm_web_instance.name
  platform_id     = var.vm_web_instance.platform_id
  resources {
    cores         = var.vm_web_instance.cores
    memory        = var.vm_web_instance.memory
    core_fraction = var.vm_web_instance.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_instance.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web_instance.nat
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = local.vm_web_ssh_user
  }
}

## task 3: database instance resource
data "yandex_compute_image" "db" {
  family = var.vm_db_instance.image_family
}
resource "yandex_compute_instance" "db-platform" {
  name            = var.vm_db_instance.name
  platform_id     = var.vm_db_instance.platform_id
  resources {
    cores         = var.vm_db_instance.cores
    memory        = var.vm_db_instance.memory
    core_fraction = var.vm_db_instance.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.db.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_instance.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_db_instance.nat
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = local.vm_db_ssh_user
  }
}