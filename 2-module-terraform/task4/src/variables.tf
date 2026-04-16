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
