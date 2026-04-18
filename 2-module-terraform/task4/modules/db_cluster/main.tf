terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
  }
}

locals {
  version = "8.0"
}

resource "yandex_vpc_subnet" "default_subnet" {
  network_id     = var.network_id
  v4_cidr_blocks = var.default_cidr
}

# @see https://yandex.cloud/ru/docs/terraform/resources/mdb_mysql_cluster
resource "yandex_mdb_mysql_cluster" "ayn_db_cluster" {
  name        = var.name
  description = var.description
  environment = var.env
  network_id  = var.network_id
  folder_id   = var.folder_id
  version     = local.version

  resources {
    resource_preset_id = var.resouces.resource_preset_id
    disk_type_id       = var.resouces.disk_type_id
    disk_size          = var.resouces.disk_size
  }

  mysql_config = {
    sql_mode                      = var.sql_mode
    max_connections               = var.max_connections
    default_authentication_plugin = var.auth_plugin
  }

  dynamic "host" {
    for_each = var.hosts

    content {
      zone      = host.value.zone
      subnet_id = host.value.subnet_id
    }
  }
}