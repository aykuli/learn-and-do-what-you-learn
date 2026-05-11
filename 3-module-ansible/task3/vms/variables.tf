# --- PROVIDERS ---
variable "cloud_id" {
  type = string
}
variable "folder_id" {
  type = string
}

variable "default_zone" {
  type    = string
  default = "ru-central1-d"
}

variable "servers" {
  type = list(string)
}


variable "keys_path" {
  type = string
}


# --- VMs ---
variable "vms" {
  type = object({
    name            = string
    hostname        = string
    user            = string
    ssh_key         = string

    image_family   = string
    platform_id    = string
    boot_disk_type = string
    boot_disk_size = number
    preemptible    = bool
    nat            = bool
    resources      = object({
      cores          = number
      memory        = number
      core_fraction = number
    })
  })
}

variable "container_registry_name" {
  type = string
  default = "ayn-registry"
}
# ---

variable "vpc" {
  type = object({
    network_name   = string
    subnet_name    = string
    v4_cidr_blocks = list(string)
  })
  default = {
    network_name   = "ayn-netw"
    subnet_name    = "ayn-subn"
    v4_cidr_blocks = ["10.0.1.0/16"]
  }
}
