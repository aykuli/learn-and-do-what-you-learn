resource "yandex_vpc_gateway" "nat_gateway_of_aynur" {
  folder_id = var.folder_id
  name = "aynur-gateway"
  shared_egress_gateway {
    
  }
}

resource "yandex_vpc_route_table" "aynur_rt" {
  folder_id = var.folder_id
  name = "aynur-route-table"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.nat_gateway_of_aynur.id
  }
}

resource "yandex_vpc_network" "develop" {
  folder_id = var.folder_id
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
  route_table_id = yandex_vpc_route_table.aynur_rt.id
}

data "yandex_compute_image" "ubuntu" {
  family = var.vms_resources.web.image_family
}
resource "yandex_compute_instance" "platform" {
  name            = local.vm_web_name
  platform_id     = var.vms_resources.web.platform_id
  resources {
    cores         = var.vms_resources.web.cores
    memory        = var.vms_resources.web.memory
    core_fraction = var.vms_resources.web.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vms_resources.web.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = false
  }

  metadata = var.metadata
}

## task 3: database instance resource
resource "yandex_compute_instance" "db-platform" {
  name            = local.vm_db_name
  platform_id     = var.vms_resources.db.platform_id
  resources {
    cores         = var.vms_resources.db.cores
    memory        = var.vms_resources.db.memory
    core_fraction = var.vms_resources.db.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vms_resources.db.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vms_resources.db.nat
  }

  metadata = var.metadata
}