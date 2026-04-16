module "vpc_dev" {
  source = "./modules/vpc"
  folder_id = var.folder_id
  zone = var.default_zone
  vpc_env = var.vpc_env
  cidr = var.default_cidr.0
}

module "marketing_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  network_id     = module.vpc_dev.subnet.network_id
  subnet_ids     = [module.vpc_dev.subnet.id]
  subnet_zones   = [module.vpc_dev.subnet.zone]
  platform       = var.default_vm_instance.platform_id
  
  instance_name  = "${var.vm_labels.0}-${var.default_vm_instance.name}"
  instance_count = 1
  image_family   = var.default_vm_instance.image_family
  public_ip      = var.default_vm_instance.nat

  boot_disk_size = var.default_vm_instance.disk_size
  boot_disk_type = var.default_vm_instance.disk_type
  instance_core_fraction = var.default_vm_instance.core_fraction
  instance_cores         =  var.default_vm_instance.cores
  instance_memory        = var.default_vm_instance.memory
  preemptible            = var.default_vm_instance.preemptible

  labels = { 
    owner   = var.vm_user,
    project = var.vm_labels.0
  }
  metadata = {
    user-data = templatefile("cloud-init.yml",{
      vm_user        = var.vm_user
      ssh_public_key = var.ssh_key
    })
    serial-port-enable = 1
  }
}

module "analytics_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  network_id     = module.vpc_dev.subnet.network_id
  subnet_ids     = [module.vpc_dev.subnet.id]
  subnet_zones   = [module.vpc_dev.subnet.zone]
  
  platform       = var.default_vm_instance.platform_id
  
  instance_name  = "${var.vm_labels.1}-${var.default_vm_instance.name}"
  instance_count = 1
  image_family   = var.default_vm_instance.image_family
  public_ip      = var.default_vm_instance.nat

  boot_disk_size = var.default_vm_instance.disk_size
  boot_disk_type = var.default_vm_instance.disk_type
  instance_core_fraction = var.default_vm_instance.core_fraction
  instance_cores         =  var.default_vm_instance.cores
  instance_memory        = var.default_vm_instance.memory
  preemptible            = var.default_vm_instance.preemptible

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