terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
  }
  required_version = ">=1.12.0"
}

locals {
  version = "8.0"
}

resource "yandex_vpc_subnet" "cluster_subnets" {
  count = length(var.zones)

  network_id = var.network_id
  folder_id = var.folder_id
  v4_cidr_blocks = var.subnet_cidrs[count.index]
}

# @see https://yandex.cloud/ru/docs/terraform/resources/mdb_mysql_cluster
resource "yandex_mdb_mysql_cluster" "ayn_db_cluster" {
  name        = var.name
  description = var.description
  environment = var.env
  network_id  = var.network_id
  folder_id   = var.folder_id
  version     = local.version
  security_group_ids = var.security_group_ids

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
    # HA cluster should contain at least 2 hosts
    for_each = var.HA ? var.zones : [var.zones[0]]

    content {
      zone             = host.value
      subnet_id        = yandex_vpc_subnet.cluster_subnets[host.key].id
      assign_public_ip = false
    }
  }
}