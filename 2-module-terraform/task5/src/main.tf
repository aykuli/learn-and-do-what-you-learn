data "yandex_compute_image" "ubuntu" {
  family = var.vm.image_family
}
resource "yandex_vpc_network" "aynnetw" {
  folder_id = var.folder_id
  name      = var.net_name
}

resource "yandex_vpc_subnet" "aynsubnet" {
  network_id = yandex_vpc_network.aynnetw.id
  name       = var.subnet_name
  v4_cidr_blocks = var.subnet_cidr_blocks
}



resource "yandex_compute_instance" "vm" {
  name        = var.vm.name
  hostname    = var.vm.hostname
  folder_id   = var.folder_id
  platform_id = var.vm.platform_id

  resources {
    cores         = var.vm.cores
    memory        = var.vm.memory
    core_fraction = var.vm.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.aynsubnet.id
    nat       = var.vm.nat
  }
  scheduling_policy {
    preemptible = var.vm.preemptible
  }
  metadata = {
    user-data = templatefile("cloud-init.yml",{
      vm_user        = var.vm_user
      ssh_public_key = var.ssh_key
    })
    serial-port-enable = 1
  }
}

output "ip" {
  value = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}