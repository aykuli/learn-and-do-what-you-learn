variable "folder_id" {
  type = string
}
variable "cloud_id" {
  type = string
}

variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

variable "vpc_env" {
  type = string
  default = "development"  
}

variable "bucket" {
  type = string
  default = "my-bucket"
}