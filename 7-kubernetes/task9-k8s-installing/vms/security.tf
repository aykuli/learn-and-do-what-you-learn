variable "security_group_ingress" {
  description = "security rules ingress"
  type = list(object({
    protocol       = string
    description    = string
    v4_cidr_blocks = optional(list(string))
    port           = optional(number)
    from_port      = optional(number)
    to_port        = optional(number)
    predefined_target = optional(string) # Добавлено для внутренних правил Яндекса
  }))
  default = [
    {
      protocol       = "TCP"
      description    = "разрешить входящий ssh"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 22
    },
    {
      protocol       = "TCP"
      description    = "Kubernetes API Server (Kubeadm init/join и kubectl)"
      v4_cidr_blocks = ["0.0.0.0/24"] # Мой домашний IР
      port           = 6443
    },
    {
      protocol       = "ANY"
      description    = "Полное взаимодействие между нодами внутри этой же SG"
      predefined_target = "self_security_group" # Разрешает всё между мастером и воркерами
    },
    {
      protocol       = "TCP"
      description    = "разрешить входящий http"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 80
    },
    {
      protocol       = "TCP"
      description    = "разрешить входящий https"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 443
    }
  ]
}

variable "security_group_egress" {
  description = "security rules egress"
  type = list(object({
    protocol       = string
    description    = string
    v4_cidr_blocks = optional(list(string))
    port           = optional(number)
    from_port      = optional(number)
    to_port        = optional(number)
  }))
  default = [
    { 
      protocol       = "ANY" # Меняем TCP на ANY, чтобы работал UDP (нужен для DNS и Calico)
      description    = "разрешить весь исходящий трафик во внешний мир"
      v4_cidr_blocks = ["0.0.0.0/0"]
      from_port      = 0
      to_port        = 65535 # Исправлена опечатка (было 65365)
    }
  ]
}



resource "yandex_vpc_security_group" "aynurs-sg" {
  name       = "aynurs-sg"
  network_id = yandex_vpc_network.k8s-network.id
  folder_id  = var.folder_id

  dynamic "ingress" {
    for_each = var.security_group_ingress
    content {
      protocol       = lookup(ingress.value, "protocol", null)
      description    = lookup(ingress.value, "description", null)
      port           = lookup(ingress.value, "port", null)
      from_port      = lookup(ingress.value, "from_port", null)
      to_port        = lookup(ingress.value, "to_port", null)
      v4_cidr_blocks = lookup(ingress.value, "v4_cidr_blocks", null)
      predefined_target = lookup(ingress.value, "predefined_target", null)
    }
  }

  dynamic "egress" {
    for_each = var.security_group_egress
    content {
      protocol       = lookup(egress.value, "protocol", null)
      description    = lookup(egress.value, "description", null)
      port           = lookup(egress.value, "port", null)
      from_port      = lookup(egress.value, "from_port", null)
      to_port        = lookup(egress.value, "to_port", null)
      v4_cidr_blocks = lookup(egress.value, "v4_cidr_blocks", null)
    }
  }
}
