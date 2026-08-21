resource "yandex_compute_instance" "workers" {
  count       = 4
  name        = "k8s-worker-${count.index + 1}"
  hostname    = "k8s-worker-${count.index + 1}"
  platform_id = var.vm.platform_id

  resources {
    cores  = var.vm.cores
    memory = var.vm.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vm.disk_size
      type     = var.vm.disk_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.k8s-subnet.id
    security_group_ids = [ yandex_vpc_security_group.aynurs-sg.id ]
    nat       = var.vm.nat
  }

  metadata = {
    user-data = templatefile("cloud-init.yml",{
      vm_user        = var.vm_user
      ssh_public_key = var.ssh_key
    })
    serial-port-enable = 1
  }

  depends_on = [yandex_compute_instance.master]
}