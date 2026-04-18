resource "yandex_vpc_network" "vpc_network" {
  name = var.network_name
}

module "example" {
  depends_on = [ yandex_vpc_network.vpc_network ]

  source     = "../modules/db_cluster"
  name       = "aynurs-awesome-db-cluster"

  network_id = yandex_vpc_network.vpc_network.id
  subnet_cidrs = var.subnet_cidrs
  folder_id  = var.folder_id
  zones      = var.zones
  HA         = var.HA
}

module "mysql_db" {
  depends_on = [ module.example ]

  source = "../modules/db_database"

  cluster_id  = module.example.cluster.id

  db_name     = var.db.name
  username    = var.db.user
  password    = var.db.password
  auth_plugin = var.db.auth_plugin
}
