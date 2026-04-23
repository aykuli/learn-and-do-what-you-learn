resource "yandex_mdb_postgresql_cluster" "pg_cluster" {
  name        = var.db_cluster_name
  environment = var.db_cluster_env
  network_id  = local.network_id
  folder_id   = var.folder_id
  security_group_ids = [ yandex_vpc_security_group.db_sg.id ]
  config {
    version = var.pg_version
    resources {
      resource_preset_id = var.pg_config.resources.resource_preset_id
      disk_type_id       = var.pg_config.resources.disk_type_id
      disk_size          = var.pg_config.resources.disk_size
    }
    postgresql_config = { max_connections = var.pg_config.max_connections }
    access { web_sql = var.pg_config.web_sql_access }
  }
  host {
    zone      = var.default_zone
    subnet_id = local.subnet_id
    assign_public_ip = var.pg_assign_public_ip
  }
}
locals {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
}

resource "yandex_mdb_postgresql_user" "pg_manager" {
  depends_on = [ yandex_mdb_postgresql_cluster.pg_cluster ]

  cluster_id = local.cluster_id
  name       = var.db_user
  password   = var.db_pwd
}
locals {
  db_owner_name = yandex_mdb_postgresql_user.pg_manager.name
}

resource "yandex_mdb_postgresql_database" "pg_db" {
  depends_on = [ yandex_mdb_postgresql_cluster.pg_cluster ]

  cluster_id = local.cluster_id
  name       = var.db_name
  owner      = local.db_owner_name
  lc_collate = var.db_posix_locale
  lc_type    = var.db_posix_locale
  dynamic "extension" {
    for_each = var.db_extensions
    content {
      name = extension.value
    }
  }
}