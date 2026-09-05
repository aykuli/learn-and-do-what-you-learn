data "yandex_compute_image" "ubuntu-image" {
  family = var.vm.image_family
}

resource "yandex_compute_instance" "ayn-public-vm" {
  name               = "public-vm"
  hostname           = "public-vm"
  folder_id          = var.folder_id
  platform_id        = var.vm.platform_id
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-image.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.ayn-public-subent.id
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
    user-data = templatefile("config.yml",{
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
    ssh-keys = "${var.vm_user}:${var.ssh_key}"
  }
}

resource "yandex_compute_instance" "ayn-private-vm" {
  name               = "private-vm"
  hostname           = "private-vm"
  folder_id          = var.folder_id
  platform_id        = var.vm.platform_id
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-image.id
      size     = 20
      type     = "network-hdd"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.ayn-private-subnet.id
    nat       = false
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
    user-data = templatefile("config.yml",{
      VM_USER = var.vm_user
      SSH_KEY = var.ssh_key
    })
    ssh-keys = "${var.vm_user}:${var.ssh_key}"
  }
}