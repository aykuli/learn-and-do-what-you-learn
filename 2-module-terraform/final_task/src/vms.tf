data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}
locals {
  image_id = data.yandex_compute_image.ubuntu.id
}

resource "yandex_compute_instance" "web" {
  name = "web-vm"
  hostname = "web-host"
  folder_id = var.folder_id
  platform_id = "standard-v1"

  resources {
    cores = 2
    memory = 1
    core_fraction = 5
  }
  
  network_interface {
    subnet_id = local.subnet_id
    nat = true
  }

  boot_disk {
    initialize_params {
      image_id = local.image_id
      type = "network-hdd"
      size = 10
    }
  }
  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = templatefile("cloud-init.yml", {
      vm_user        = var.web_vm.user
      ssh_public_key = var.web_vm.ssh_key,
      app_folder     = var.web_vm.app_folder,
      deploy_key     = indent(6, file(var.web_vm.deploy_key_path))

      db_name        = var.db_name,
      db_pwd         = var.db_pwd,
      db_user        = var.db_user,
      db_port        = var.db_port,
      db_host        = var.db_host,
    })
  }

  # lifecycle {
  #   replace_triggered_by = [ terrafrom_data.cloud_init_config ]
  # }
}

