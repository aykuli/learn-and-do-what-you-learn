output "cluster" {
  value = {
    name:      yandex_mdb_mysql_cluster.ayn_db_cluster.name
    id:        yandex_mdb_mysql_cluster.ayn_db_cluster.id
    labels:    yandex_mdb_mysql_cluster.ayn_db_cluster.labels
    resources: yandex_mdb_mysql_cluster.ayn_db_cluster.resources
    status:    yandex_mdb_mysql_cluster.ayn_db_cluster.status
    version:   yandex_mdb_mysql_cluster.ayn_db_cluster.version
  }
}