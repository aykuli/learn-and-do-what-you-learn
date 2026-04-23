output "db_info" {
  value = {
    db:      module.mysql_db
    cluster: module.example
  }
}