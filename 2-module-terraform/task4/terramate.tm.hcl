terramate {
  config {
  }
}

globals {
  cloud_id  = "b1gn911ma8o0654hir1g"
  folder_id = "b1g8vvncr37co225u3jm"
  zone      = "ru-central1-a"
  
  key_file = "~/authorized_key.json"
  terraform_version = "=>1.12.0"
}

generate_hcl "providers.tf" {
  content {
    terraform {
      required_providers {
        yandex = {
          source = "yandex-cloud/yandex"
          version = ">= 0.47.0"
        }
      }
    }

    provider "yandex" {
      cloud_id                 = var.cloud_id
      folder_id                = var.folder_id
      zone                     = var.default_zone
      service_account_key_file = file(global.key_file)
    }
  }
}

# @see https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-storage
generate_hcl "backend.tf" {
  content {
    terraform {
      backend "s3" {
        endpoint = "https://storage.yandexcloud.net"
        bucket   = "ayn-terra"
        key      = "${terramate.stack.path.relative}/terraform.tfstate"

        region                      = "ru-central1"
        skip_region_validation      = true
        skip_credentials_validation = true
        skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
        skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
      }
    }
  }
}

generate_hcl "variables.tf" {
  content {
    variable "folder_id" {
      type = string
    }
    variable "cloud_id" {
      type = string
    }

    variable "vm_user" {
      type = string
    }

    variable "ssh_key" {
      type      = string
      sensitive = true
    }

    variable "default_zone" {
      type    = string
      default = "ru-central1-a"
    }

    variable "network_name" {
      type = string
      default = "ayn-netw"
    }

    variable "subnet_name" {
      type = string
      default = "ayn-subnet"
    }

    variable "default_cidr" {
      type = list(string)
      default = [ "10.0.1.0/24" ]
    }

    variable "vm_labels" {
      type = list(string)
      default = [ ]
    }

    variable "default_vm_instance" {
      type = object({
        image_family  = string
        platform_id   = string
        name          = string
        hostname      = string
        disk_type     = string
        disk_size     = number
        preemptible   = bool
        cores         = number
        memory        = number
        core_fraction = number
        nat           = bool
      })
      default = {
        image_family  = "ubuntu-2204-lts"
        platform_id   = "standard-v1"
        name          = "aynurs-vm"
        hostname      = "aynurs-hn"
        disk_type     = "network-hdd"
        disk_size     = 10
        preemptible   = true
        cores         = 1
        memory        = 1
        core_fraction = 5
        nat           = true
      }
    }

    # task 2. for vpc module
    variable "vpc_env" {
      type = string
      default = "development"  
    }

    variable "vpc_env_prod" {
      type = string
      default = "production"
    }

    # task 4
    variable "prod_subnets" { type = list(map(string)) }

    variable "dev_subnets" { type = list(map(string)) }

    # backend
    variable "bucket_name" {
      type = string
    }
    variable "access_key" {
      type = string
    }

    variable "secret_key" {
      type = string
    }
  }
}