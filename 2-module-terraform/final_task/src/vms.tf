resource "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}
locals {
  image_id = yandex_compute_image.ubuntu.id
}

resource "yandex_compute_instance" "web" {
  name = "web-vm"

  resources {
    cores = 2
    memory = 1
    core_fraction = 5
  }
  
  network_interface {
    subnet_id = local.subnet_id
  }

  boot_disk {
    initialize_params {
      image_id = local.image_id
    }
  }
  metadata = {
    user-data = templatefile("cloud-init.yml", {
      vm_user        = var.web_vm.user
      ssh_public_key = var.web_vm.ssh_key
    })
  }
}

