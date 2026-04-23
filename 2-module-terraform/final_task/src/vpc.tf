resource "yandex_vpc_network" "ayn_netw" {
  name      = var.vpc.network_name
  folder_id = local.folder_id
}
locals {
  network_id = yandex_vpc_network.ayn_netw.id
}

resource "yandex_vpc_subnet" "ayn_subn" {
  name       = var.vpc.subnet_name
  network_id = local.network_id
  v4_cidr_blocks = var.vpc.v4_cidr_blocks
}
locals {
  subnet_id = yandex_vpc_subnet.ayn_subn.id
}


resource "yandex_vpc_security_group" "web_sg" {
  name        = "web-sg"
  description = "for web vms"
  network_id  = local.network_id

  ingress {
    description = "Allow HTTPS"
    protocol = "TCP"
    port = 443
  }
  ingress {
    description = "Allow HTTP"
    protocol = "TCP"
    port = 80
  }
  ingress {
    description = "Allow SSH"
    protocol = "SSH"
    port = 22
  }
  egress {
    description = "Permit ANY"
    protocol = "HTTP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    description = "Permit ANY"
    protocol = "HTTPS"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "yandex_vpc_security_group" "db_sg" {
  name = "db-sq"
  description = "for db cluster"
  network_id  = local.network_id
  
  ingress {
    description = "Permit access only my web vms"
    protocol = "TCP"
    port     = 5432
    security_group_id = yandex_vpc_security_group.web_sg.id
  }
}

