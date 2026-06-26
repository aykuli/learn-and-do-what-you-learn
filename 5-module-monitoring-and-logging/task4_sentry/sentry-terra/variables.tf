variable "network_id" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "default_zone" {
  type = string
  default = "ru-central1-d"
}
variable "folder_id" {
  type = string
}
variable "cloud_id" {
  type = string
}
variable "service_account_id" {
  type = string
}

variable "ssh_key" {
  type = string
}
variable "meta_user_data" {
  type = string
}
variable "vm_user" {
  type = string
}