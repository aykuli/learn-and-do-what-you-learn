resource "yandex_vpc_network" "vpc_network" {
  name = var.network_name
}

resource "yandex_vpc_security_group" "cluster_sg" {
  name = var.sg_name
  network_id = local.vpc_network.id
}

locals {
  sg_id      = yandex_vpc_security_group.cluster_sg.id
  vpc_network = yandex_vpc_network.vpc_network
}
module "example" {
  depends_on = [ vpc_network ]

  source     = "../modules/db_cluster"
  name       = "aynurs-awesome-db-cluster"

  network_id = local.vpc_network.id
  security_group_ids = [local.sg_id]
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
