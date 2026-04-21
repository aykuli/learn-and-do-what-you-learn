stack {
  name        = "vms"
  description = "vms"
}


# Сначала попробовала локальный, а потом уже позарилась на удалённый
# generate_hcl "remote_states.tf" {
#   content {
#     data "terraform_remote_state" "vpc" {
#       backend = "local"
#       config = {
#         path = "../vpc/terraform.tfstate"
#       }
#     }
#   }
# }

generate_hcl "remote_states.tf" {
  content {
    data "terraform_remote_state" "vpc" {
      backend = "s3"
      config = {
        endpoints = {
          s3 = "https://storage.yandexcloud.net"
        }
        bucket = var.bucket_name
        region = "ru-central1"
        key    = "vpc/terraform.tfstate"
        skip_region_validation      = true
        skip_credentials_validation = true
        skip_requesting_account_id  = true

        access_key = var.access_key
        secret_key = var.secret_key
      }
    }
  }
}

generate_hcl "main.tf" {
  content {
    locals {
      prod_subnets = data.terraform_remote_state.vpc.outputs.prod_subnets
    }

    module "marketing_vm" {
      source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=v1.0.0"
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
      source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=v1.0.0"
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

  }
}

generate_hcl "outputs.tf" {
  content {
    output "vms" {
      value = {
        marketings_ips: module.marketing_vm.external_ip_address,
        analytics_ips:  module.analytics_vm.external_ip_address
      }
    }
  }
}


