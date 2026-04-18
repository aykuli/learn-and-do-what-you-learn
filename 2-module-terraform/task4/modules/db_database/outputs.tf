output "database" {
  value = {
    db: yandex_mdb_mysql_database_v2.db,
    db_creds: yandex_mdb_mysql_user.user
  }
}