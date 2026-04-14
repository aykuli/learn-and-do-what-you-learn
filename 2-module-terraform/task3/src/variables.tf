###cloud vars
variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "image_family" {
  type  = string
  default = "ubuntu-2204-lts"
}

variable "vm_user" {
  type = string
}

variable "default_boot_disk" {
  type = object({
    core_fraction = number
    size          = number
    type          = string
  })
  default = {
    core_fraction = 5
    size = 5
    type = "network-hdd"
  }
}

variable "default_vm_instance" {
  type = object({
    disk_type     = string
    disk_size     = number
    platform_id   = string
    preemptible   = bool
    cores         = number
    memory        = number
    core_fraction = number
    nat           = bool
  })
  default = {
    disk_type     = "network-hdd"
    disk_size     = 5
    platform_id   = "standard-v1"
    preemptible   = true
    cores         = 2
    memory        = 1
    core_fraction = 5
    nat           = false
  }
}

# count-vm.tf
variable "web_vm_name" {
  type   = string
  default = "web"
}

# for_each-vm.rf
variable "db_nat" {
  type    = bool
  default = false
}
variable "each_vm" {
  type = list(object({
    vm_name       = string
    cpu           = number
    ram           = number
    core_fraction = number
    disk_volume   = number
  }))
}
