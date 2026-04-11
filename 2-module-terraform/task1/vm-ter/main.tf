# @note tutorial
# https://yandex.cloud/ru/docs/compute/tutorials/coi-with-terraform

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "random_password" "random_string" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

output "external_ip" {
  value = yandex_compute_instance.aynur_vm_from_terra_resource.network_interface.0.nat_ip_address
}

