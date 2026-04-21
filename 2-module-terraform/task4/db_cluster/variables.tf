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

variable "db" {
  type = object({
    name     = string
    user     = string
    password = string

    auth_plugin = string
  })
}

variable "zones" {
  type = list(string)
  default = [ "ru-central1-a", "ru-central1-b" ]
}

variable "network_name" {
  type = string
  default = "clusters_network"
}
variable "HA" {
  type = bool
  default = false
}

variable "subnet_cidrs" {
  type = list(list(string))
  default = [[ "10.0.1.0/24"]]
}

variable "sg_name" {
  type = string
  default = "sg-cluster"
}