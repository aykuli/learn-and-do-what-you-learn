variable "zone" {
  type = string
  description = "https://yandex.cloud/ru/docs/overview/concepts/geo-scope"
}

variable "folder_id" {
  type = string
  description = "Provider folder you are going to work in"
}

variable "vpc_env" {
  type = string
  default = "development"  
  description = "Will be used in name templates of network and it's subnet"
}

variable "cidr" {
  type = string
  description = "XX.XX.XX.XX/XX"
}