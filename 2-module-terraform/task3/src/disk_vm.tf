variable "disk_name" {
  type = string
  default = "my_awesome_disk"
}
variable "storage_name" {
  type = string
  default = "my_awesome_storage"
}

resource "yandex_compute_disk" "aynurs_disks" {
  count = 3

  folder_id = var.folder_id
  name      = "${var.disk_name}-${count.index}"
  zone      = var.default_zone
  type      = var.default_vm_instance.disk_type
  size      = var.default_vm_instance.disk_size
}

resource "yandex_compute_instance" "storage" {
  name = var.storage_name
  platform_id = var.default_vm_instance.platform_id

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ayn_image.image_id
    }
  }

  resources {
    cores         = var.default_vm_instance.cores
    memory        = var.default_vm_instance.memory
    core_fraction = var.default_vm_instance.core_fraction
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_subnet.id
    nat       = var.default_vm_instance.nat
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.aynurs_disks
    content {
      disk_id = secondary_disk.value.id
    }
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("~/.ssh/id_rsa.pub/")}"
  }
  
  allow_stopping_for_update = true
}