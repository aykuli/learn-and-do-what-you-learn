data "yandex_compute_image" "ubuntu" {
  family = var.vms.image_family
}

resource "yandex_compute_instance" "task3_vms" {
  count = 3
  
  folder_id   = var.folder_id
  name        = var.servers[count.index]
  hostname    = var.servers[count.index]
  platform_id = var.vms.platform_id
  zone        = var.default_zone

  network_interface {
    subnet_id = yandex_vpc_subnet.ayn_subn.id
    nat       = var.vms.nat
  }

  resources {
    cores         = var.vms.resources.cores
    memory        = var.vms.resources.memory
    core_fraction = var.vms.resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = var.vms.boot_disk_type
      size     = var.vms.boot_disk_size
    }
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = templatefile("cloud-init.yml", {
      vm_user        = var.vms.user,
      ssh_public_key = var.vms.ssh_key,
    })
  }
}
