module "vpc" {
  source    = "../modules/vpc"
  folder_id = var.folder_id
  env_name  = var.vpc_env
  subnets   = var.prod_subnets
}

module "mysqldb_cluster" {
  source     = "./modules/db_cluster"
  name       = "aynurs-awesome-db-cluster"
  folder_id  = var.folder_id
  network_id = module.vpc.subnets.0.network_id
  hosts = [{ 
    zone             = module.vpc.subnets.0.zone
    subnet_id        = module.vpc.subnets.0.id
    assign_public_ip = true
  }]

  # hosts = [for item in  var.prod_subnets : {
  #   zone = item.zone
  #   subnet_id = module.vpc.subnets.0.id
  # assign_public_ip = true
  # }]
}

module "mysql_db" {
  source = "./modules/db_database"

  cluster_id  = module.mysqldb_cluster.cluster.id
  username    = var.db.user
  password    = var.db.password
  auth_plugin = var.db.auth_plugin
}