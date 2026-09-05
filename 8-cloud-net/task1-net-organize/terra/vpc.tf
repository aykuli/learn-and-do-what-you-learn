resource "yandex_vpc_network" "ayn-net" {
  name      = "ayn-net"
  folder_id = var.folder_id
}

resource "yandex_vpc_gateway" "ayn_nat_gateway" {
  folder_id = var.folder_id
  name      = "ayn-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "ayn_rt" {
  folder_id = var.folder_id
  name = "ayn_rt"
  network_id = yandex_vpc_network.ayn-net.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.ayn_nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "ayn-public-subent" {
  name      = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]

  network_id = yandex_vpc_network.ayn-net.id
}

resource "yandex_vpc_subnet" "ayn-private-subnet" {
  name      = "private"
  v4_cidr_blocks = ["192.168.20.0/24"]

  network_id = yandex_vpc_network.ayn-net.id
  route_table_id = yandex_vpc_route_table.ayn_rt.id
}
