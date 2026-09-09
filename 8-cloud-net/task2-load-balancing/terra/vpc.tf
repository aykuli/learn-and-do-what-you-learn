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

resource "yandex_vpc_security_group" "ayn-sg" {
  name        = "ayn-sg"
  description = "allow to get image from storage"
  network_id  = yandex_vpc_network.ayn-net.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
    description    = "Allow SSH"
  }

  ingress {
    protocol    = "TCP"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port        = 80
    description = "Allow HTTP"
  }

  ingress {
    protocol    = "TCP"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port        = 443
    description = "Allow HTTPS"
  }
  
  ingress {
    protocol          = "TCP"
    description       = "Allow Yandex Load Balancer Health Checks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 80
  }

  egress {
    protocol       = "ANY"
    description    = "Всё можно качать из интернета"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = -1
    to_port        = -1
  }
}
