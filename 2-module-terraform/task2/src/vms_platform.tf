### task 2 vars
variable "vm_web_instance" {
  type    = object({
    name          = string
    image_family  = string
    platform_id   = string
    zone          = string
    cores         = number
    memory        = number
    core_fraction = number
    preemptible   = bool
    nat           = bool
    metadata      = object({
      ssh_user    =  string
    })
  })
  default = {
    name          = "netology-develop-platform-web"
    image_family  = "ubuntu-2004-lts"
    platform_id   = "standard-v1"
    zone          = "ru-central1-a"
    cores         = 2
    memory        = 2
    core_fraction = 20
    preemptible   = true
    nat           = true
    metadata      = {
      ssh_user    = "aynur"
    }
  }
}

## task 3: database vars
variable "vm_db_instance" {
  type    = object({
    name          = string
    image_family  = string
    platform_id   = string
    zone          = string
    cores         = number
    memory        = number
    core_fraction = number
    preemptible   = bool
    nat           = bool
    metadata      = object({
      ssh_user    =  string
    })
  })
  default = {
    name          = "netology-develop-platform-db"
    image_family  = "ubuntu-2004-lts"
    platform_id   = "standard-v1"
    zone          = "ru-central1-b"
    cores         = 2
    memory        = 2
    core_fraction = 20
    preemptible   = true
    nat           = true
    metadata      = {
      ssh_user    = "aynur"
    }
  }
}
