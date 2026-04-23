resource "yandex_vpc_network" "ayn_netw" {
  name      = var.vpc.network_name
  folder_id = var.folder_id
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
  name        = var.sg.web.name
  description = var.sg.web.description
  labels      = var.sg.web.labels

  network_id  = local.network_id

  dynamic "ingress" {
    for_each = var.sg.web.ingress_rules

    content {
      protocol       = lookup(ingress.value, "protocol", null)
      description    = lookup(ingress.value, "description", null)
      port           = lookup(ingress.value, "port", null)
      v4_cidr_blocks = lookup(ingress.value, "v4_cidr", null)
    }    
  }
  dynamic "egress" {
    for_each = var.sg.web.ingress_rules

    content {
      protocol       = lookup(egress.value, "protocol", null)
      description    = lookup(egress.value, "description", null)
      port           = lookup(egress.value, "port", null)
      v4_cidr_blocks = lookup(egress.value, "v4_cidr", null)
    }    
  }
}

resource "yandex_vpc_security_group" "db_sg" {
  name = "db-sq"
  description = "for db cluster"
  network_id  = local.network_id

  dynamic "ingress" {
    for_each = var.sg.web.ingress_rules

    content {
      protocol       = lookup(ingress.value, "protocol", null)
      description    = lookup(ingress.value, "description", null)
      port           = lookup(ingress.value, "port", null)
      v4_cidr_blocks = lookup(ingress.value, "v4_cidr", null)
      security_group_id = yandex_vpc_security_group.web_sg.id
    }
  }
}

