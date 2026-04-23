resource "yandex_mdb_postgresql_cluster" "pg_cluster" {
  name = "pg-cluster"
  environment = "PRESTABLE"
  network_id = local.network_id
  config {
    version = 18
    resources {
      resource_preset_id = "b1.medium"
      disk_type_id = "network-hdd"
      disk_size = 10
    }
    postgresql_config = {
      max_connections = 10
    }
  }

  host {
    zone = var.default_zone
    subnet_id = local.subnet_id
  }
}
locals {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
}

resource "yandex_mdb_postgresql_user" "pg_manager" {
  cluster_id = local.cluster_id
  name       = "aynur"
  password   = "aynur^1987"
}
locals {
  db_owner_name = yandex_mdb_postgresql_user.pg_manager.name
}

resource "yandex_mdb_postgresql_database" "pg_db" {
  cluster_id = local.cluster_id
  name       = "ayn-test-db"
  owner      = local.db_owner_name
  lc_collate = "ru_RU.UTF-8"
  lc_type    = "ru_RU.UTF-8"
  extension {
    name = "uuid-ossp"
  }
  extension {
    name = "pg_partman"
  }
  extension {
    name = "postgis"
  }
  extension {
    name = "pg_stat_statements"
  }
}