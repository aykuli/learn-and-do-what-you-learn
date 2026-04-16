resource "yandex_vpc_network" "aynur-network" {
  name      = var.network_name
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "aynur-subnet" {
  name           = var.subnet_name
  v4_cidr_blocks = var.default_cidr
  network_id     = yandex_vpc_network.aynur-network.id
  zone           = var.default_zone
}

module "marketing_vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  network_id     = yandex_vpc_network.aynur-network.id
  subnet_zones   = [var.default_zone]
  subnet_ids     = [yandex_vpc_subnet.aynur-subnet.id]
  platform       = var.default_vm_instance.platform_id
  
  instance_name  = "${var.vm_labels.0}-${var.default_vm_instance.name}"
  instance_count = 1
  image_family   = var.default_vm_instance.image_family
  public_ip      = var.default_vm_instance.nat

  boot_disk_size = var.default_vm_instance.disk_size
  boot_disk_type = var.default_vm_instance.disk_type
  instance_core_fraction = var.default_vm_instance.core_fraction
  instance_cores =  var.default_vm_instance.cores
  instance_memory = var.default_vm_instance.memory
  preemptible    = var.default_vm_instance.preemptible

  labels = { 
    owner   = var.vm_user,
    project = var.vm_labels.0
  }
  metadata = {
    user-data = templatefile("cloud-init.yml",{
      vm_user = var.vm_user
      ssh_public_key = var.ssh_key
    })
    serial-port-enable = 1
  }
}
module "analytics_vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  network_id     = yandex_vpc_network.aynur-network.id
  subnet_zones   = [var.default_zone]
  subnet_ids     = [yandex_vpc_subnet.aynur-subnet.id]
  platform       = var.default_vm_instance.platform_id
  
  instance_name  = "${var.vm_labels.1}-${var.default_vm_instance.name}"
  instance_count = 1
  image_family   = var.default_vm_instance.image_family
  public_ip      = var.default_vm_instance.nat

  boot_disk_size = var.default_vm_instance.disk_size
  boot_disk_type = var.default_vm_instance.disk_type
  instance_core_fraction = var.default_vm_instance.core_fraction
  instance_cores =  var.default_vm_instance.cores
  instance_memory = var.default_vm_instance.memory
  preemptible    = var.default_vm_instance.preemptible

  labels = { 
    owner   = var.vm_user,
    project = var.vm_labels.1
  }
  metadata = {
    user-data = templatefile("cloud-init.yml",{
      vm_user = var.vm_user
      ssh_public_key = var.ssh_key
    })
    serial-port-enable = 1
  }
}