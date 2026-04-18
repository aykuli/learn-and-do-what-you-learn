module "vpc_dev" {
  source    = "../modules/vpc"
  folder_id = var.folder_id
  env_name  = var.vpc_env
  subnets   = var.dev_subnets
}

module "vpc_prod" {
  source    = "../modules/vpc"
  folder_id = var.folder_id
  env_name  = var.vpc_env_prod
  subnets   = var.prod_subnets
}

locals {
  prod_subnets = module.vpc_prod.subnets
}

module "marketing_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  network_id     = local.prod_subnets.0.network_id
  subnet_ids     = [for item in local.prod_subnets : item.id]
  subnet_zones   = [for item in local.prod_subnets : item.zone]
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
  network_id     = local.prod_subnets.0.network_id
  subnet_ids     = [for item in local.prod_subnets : item.id]
  subnet_zones   = [for item in local.prod_subnets : item.zone]
  
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