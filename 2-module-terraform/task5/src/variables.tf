# --- PROVIDERS VARS ---
variable "folder_id" {
  type = string
}
variable "cloud_id" {
  type = string
}
variable "keys_path" {
  type = string
}
variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}
# ---

variable "vm_user" {
  type = string
}

variable "ssh_key" {
  type      = string
  sensitive = true
}

# --- # MODULE VARS ---
variable "service_account_name" {
  type = string
}

variable "bucket_name" {
  type = string
}
variable "state_folder" {
  type = string
}

variable "sa_role" {
  type = string
  default = "storage.editor"
}
# ---

# --- VM VARS ---
variable "net_name" {
  type = string
  default = "my-netw"
}
variable "subnet_name" {
  type = string
  default = "my-subn"
}
variable "subnet_cidr_blocks" {
  type = list(string)
  default = [ "10.10.1.0/24" ]
}

variable "vm" {
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

# ---
