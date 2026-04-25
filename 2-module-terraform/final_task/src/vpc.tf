resource "yandex_vpc_network" "ayn_netw" {
  name      = var.vpc.network_name
  folder_id = var.folder_id
}
resource "yandex_vpc_subnet" "ayn_subn" {
  name             = var.vpc.subnet_name
  network_id       = yandex_vpc_network.ayn_netw.id
  v4_cidr_blocks   = var.vpc.v4_cidr_blocks
}

resource "yandex_vpc_security_group" "web_sg" {
  name        = var.sg.web.name
  description = var.sg.web.description
  labels      = var.sg.web.labels

  network_id  = yandex_vpc_network.ayn_netw.id

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
    for_each = var.sg.web.egress_rules

    content {
      protocol       = lookup(egress.value, "protocol", null)
      description    = lookup(egress.value, "description", null)
      port           = lookup(egress.value, "port", null)
      v4_cidr_blocks = lookup(egress.value, "v4_cidr", null)
    }
  }
}

resource "yandex_vpc_security_group" "db_sg" {
  depends_on  = [ yandex_vpc_security_group.web_sg ]

  name        = var.sg.db.name
  description = var.sg.db.description
  network_id  = yandex_vpc_network.ayn_netw.id

  dynamic "ingress" {
    for_each = var.sg.db.ingress_rules

    content {
      protocol          = lookup(ingress.value, "protocol", null)
      description       = lookup(ingress.value, "description", null)
      port              = lookup(ingress.value, "port", null)
      v4_cidr_blocks    = lookup(ingress.value, "v4_cidr", null)
      # Разрешить входящий трафик на порт базы данных только от ресурсов, которым назначена группа web-sg
      security_group_id = yandex_vpc_security_group.web_sg.id
    }
  }
  dynamic "egress" {
    for_each = var.sg.db.egress_rules

    content {
      protocol       = lookup(egress.value, "protocol", null)
      description    = lookup(egress.value, "description", null)
      port           = lookup(egress.value, "port", null)
      v4_cidr_blocks = lookup(egress.value, "v4_cidr", null)
    }
  }
}

