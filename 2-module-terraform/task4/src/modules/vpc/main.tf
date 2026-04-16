# без этого блока инициализация не срабатывает. Почему-то зеркало тут срабатывает.
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
  }
}

resource "yandex_vpc_network" "vpc_network" {
  name = "${var.vpc_env}-network"
}

resource "yandex_vpc_subnet" "vpc_subnet" {
  name = "${var.vpc_env}-subnet"
  v4_cidr_blocks = [ var.cidr ]
  network_id = yandex_vpc_network.vpc_network.id
  zone = var.zone
}