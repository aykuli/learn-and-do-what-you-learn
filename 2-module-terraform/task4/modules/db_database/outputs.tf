output "database" {
  value = {
    db_id: yandex_mdb_mysql_database_v2.db.id
    db_name: yandex_mdb_mysql_database_v2.db.name
    cluster_id: yandex_mdb_mysql_database_v2.db.cluster_id
    db_username: yandex_mdb_mysql_user.user.name
  }
}