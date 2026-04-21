variable "env_name" {
  type = string
  default = "development"  
  description = "Will be used in name templates of network and it's subnet"
}

variable "subnets" { 
  type = list(object(
    {
      cidr = string
      zone = string
    }
  ))
}