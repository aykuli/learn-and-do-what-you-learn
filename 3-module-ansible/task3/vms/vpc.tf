resource "yandex_vpc_network" "ayn_netw" {
  name      = var.vpc.network_name
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "ayn_subn" {
  name             = var.vpc.subnet_name
  network_id       = yandex_vpc_network.ayn_netw.id
  v4_cidr_blocks   = var.vpc.v4_cidr_blocks
}


