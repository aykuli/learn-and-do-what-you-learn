variable "folder_id" {
  type = string
}
variable "cloud_id" {
  type = string
}

variable "vm_user" {
  type = string
}

variable "token" {
  type = string
  sensitive = true
}
variable "ssh_key" {
  type = string
  sensitive = true
}