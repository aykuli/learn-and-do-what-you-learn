variable "cloud_id" {
  type = string
}
variable "folder_id" {
  type = string
}
variable "default_zone" {
  type = string
  default = "ru-central1-d"
}

variable "vm" {
  type = object({
    image_family = string
    name         = string
    platform_id  = string
  })
  default = {
    image_family = "container-optimized-image"
    name         = "ayn-vm"
    platform_id  = "standard-v3"
  }
}


variable "ssh_key" {
  type = string
}
variable "vm_user" {
  type = string
}