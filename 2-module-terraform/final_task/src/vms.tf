data "yandex_compute_image" "ubuntu" {
  family = var.web_vm.image_family
}

resource "yandex_vpc_address" "addr" {
  name = var.static_ip.name
  external_ipv4_address {
    zone_id = var.default_zone
  }
}

resource "yandex_compute_instance" "web" {
  depends_on = [
    yandex_vpc_subnet.ayn_subn,
    yandex_vpc_security_group.web_sg,
  yandex_mdb_postgresql_cluster.pg_cluster]

  name        = var.web_vm.name
  hostname    = var.web_vm.hostname
  folder_id   = var.folder_id
  platform_id = var.web_vm.platform_id

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  network_interface {
    security_group_ids = [yandex_vpc_security_group.web_sg.id]
    subnet_id          = yandex_vpc_subnet.ayn_subn.id
    nat_ip_address     = yandex_vpc_address.addr.external_ipv4_address[0].address
    nat                = var.web_vm.nat
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = var.web_vm.boot_disk_type
      size     = var.web_vm.boot_disk_size
    }
  }
  scheduling_policy {
    preemptible = var.web_vm.preemptible
  }

  metadata = {
    user-data = templatefile("cloud-init.yml", {
      vm_user        = var.web_vm.user
      ssh_public_key = var.web_vm.ssh_key,
      app_folder     = var.web_vm.app_folder,
      deploy_key     = indent(6, file(var.web_vm.deploy_key_path))

      db_name = var.db_name,
      db_pwd  = var.db_pwd,
      db_user = var.db_user,
      db_port = var.db_port,
      db_host = yandex_mdb_postgresql_cluster.pg_cluster.host[0].fqdn
    })
    serial-port-enable = 1
  }

  # lifecycle {
  #   replace_triggered_by = [ terrafrom_data.cloud_init_config ]
  # }
}

