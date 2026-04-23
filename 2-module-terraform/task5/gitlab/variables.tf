variable "netw_name" {
  type = string
  default = "aynnetw"
}
variable "subn_name" {
  type = string
  default = "aynsubn"
}
variable "v4_cidr_blocks" {
  type = list(string)
  default = [ "10.10.1.0/24" ]
}

variable "gl_config" {
  type = object({
    name               = string
    resource_preset_id = string
    disk_size          = number
    admin_login        = string
    admin_email        = string
    domain             = string

    approval_rules_id  = string
    backup_retain_period_days = number
  })

  default = {
    name               = "my_first_gitlab_server"
    resource_preset_id = "s2.micro" # other variants s2.small, s2.medium,  s2.large
    disk_size          = 30
    admin_login        = "ayadmin"
    admin_email        = "a@b.com"
    domain             = "aynur.gitlab.yandexcloud.net"
    approval_rules_id  = "STANDARD"
    backup_retain_period_days = 7
  }
}

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
