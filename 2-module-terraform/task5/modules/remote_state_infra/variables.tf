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

variable "service_account_name" {
  type = string
}
variable "bucket_name" {
  type = string
}
variable "sa_role" {
  type = string
  default = "storage.editor"
}

