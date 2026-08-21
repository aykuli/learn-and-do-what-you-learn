data "yandex_compute_image" "ubuntu" {
  family = var.vm.image_family
}
resource "yandex_vpc_network" "k8s-network" {
  folder_id = var.folder_id
  name      = var.net_name
}

resource "yandex_vpc_subnet" "k8s-subnet" {
  network_id = yandex_vpc_network.k8s-network.id
  name       = var.subnet_name
  v4_cidr_blocks = var.subnet_cidr_blocks
}

