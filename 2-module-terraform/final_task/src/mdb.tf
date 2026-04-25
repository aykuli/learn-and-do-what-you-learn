resource "yandex_mdb_postgresql_cluster" "pg_cluster" {
  depends_on = [yandex_vpc_security_group.db_sg]

  name               = var.db_cluster_name
  environment        = var.db_cluster_env
  network_id         = yandex_vpc_network.ayn_netw.id
  folder_id          = var.folder_id
  security_group_ids = [yandex_vpc_security_group.db_sg.id]
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
    zone             = var.default_zone
    subnet_id        = yandex_vpc_subnet.ayn_subn.id
    assign_public_ip = var.pg_assign_public_ip
  }
}


resource "yandex_mdb_postgresql_user" "pg_manager" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = var.db_user
  password   = var.db_pwd
}

resource "yandex_mdb_postgresql_database" "pg_db" {
  cluster_id = yandex_mdb_postgresql_cluster.pg_cluster.id
  name       = var.db_name
  owner      = yandex_mdb_postgresql_user.pg_manager.name
  lc_collate = var.db_posix_locale
  lc_type    = var.db_posix_locale

  dynamic "extension" {
    for_each = var.db_extensions
    content { name = extension.value }
  }
}
