# без этого блока инициализация не срабатывает. Почему-то зеркало тут срабатывает.
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
  }
  required_version = ">=1.12.0"
}

resource "yandex_vpc_network" "vpc_network" {
  name = "${var.env_name}-network"
}

resource "yandex_vpc_subnet" "vpc_subnet" {
  count = length(var.subnets)
  
  name = "${var.env_name}-subnet-${count.index}"
  
  v4_cidr_blocks = [ var.subnets[count.index].cidr ]
  network_id = yandex_vpc_network.vpc_network.id
  zone = var.subnets[count.index].zone
}