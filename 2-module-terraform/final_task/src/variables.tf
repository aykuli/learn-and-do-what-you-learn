# --- PROVIDERS ---
variable "cloud_id" {
  type = string
}
variable "folder_id" {
  type = string
}

variable "keys_path" {
  type = string
}
# Zone	Subnet Name	CIDR Block (Example)	Purpose
# ru-central1-a	subnet-a	10.0.1.0/24	Resources in Zone A
# ru-central1-b	subnet-b	10.0.2.0/24	Resources in Zone B
# ru-central1-c	subnet-c	10.0.3.0/24	Resources in Zone C
variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

# ---

# --- VMs ---
variable "web_vm" {
  type = object({
    name            = string
    hostname        = string
    user            = string
    ssh_key         = string
    app_folder      = string
    deploy_key_path = string

    image_family   = string
    platform_id    = string
    boot_disk_type = string
    boot_disk_size = number
    preemptible    = bool
    nat            = bool
  })
}
variable "static_ip" {
  type = object({
    name = string
  })
}
# ---

# --- VPC ---
variable "vpc" {
  type = object({
    network_name   = string
    subnet_name    = string
    v4_cidr_blocks = list(string)
  })
  default = {
    network_name   = "ayn-netw"
    subnet_name    = "ayn-subn"
    v4_cidr_blocks = ["10.0.1.0/16"]
  }
}

variable "sg" {
  type = object({
    web = object({
      name        = string
      description = string
      labels      = map(string)
      ingress_rules = list(object({
        protocol    = string
        v4_cidr     = list(string)
        port        = optional(number)
        from_port   = optional(number)
        to_port     = optional(number)
        description = optional(string)
      }))
      egress_rules = optional(list(object({
        protocol    = string
        v4_cidr     = list(string)
        port        = optional(number)
        from_port   = optional(number)
        to_port     = optional(number)
        description = optional(string)
      })))
    }),
    db = object({
      name        = string
      description = string
      labels      = map(string)
      ingress_rules = list(object({
        protocol    = string
        v4_cidr     = list(string)
        port        = optional(number)
        from_port   = optional(number)
        to_port     = optional(number)
        description = optional(string)
      }))
      egress_rules = optional(list(object({
        protocol    = string
        v4_cidr     = list(string)
        port        = optional(number)
        from_port   = optional(number)
        to_port     = optional(number)
        description = optional(string)
      })))
    })
  })

  description = <<-EOF
  1. Входящий трафик (Ingress)
    Если нужно разрешить доступ внутри подсети:
    |-- указываете в правиле v4_cidr_blocks, который совпадает с CIDR подсети.
        Это позволит серверам одной подсети «видеть» друг друга.
    Если нужно разрешить доступ из интернета:
    |-- указывается 0.0.0.0/0. 
        При этом сам сервер должен иметь внутренний IP из диапазона подсети.
    Если нужно разрешить доступ из другой подсети той же VPC:
    |-- указываете CIDR соседней подсети (например, 10.0.2.0/24).

2. Исходящий трафик (Egress)
    Если для выхода в мир: 
    |-- 0.0.0.0/0
        Позволяет серверу, имеющему IP из диапазона подсети,
        обращаться к любым внешним ресурсам.
    Для изоляции:
    |-- Если сервер должен общаться только с базой данных в другой подсети, 
        в Egress указывается только CIDR этой конкретной подсети базы данных.

Главные правила «стыковки»:

    Вложенность: IP-адрес сетевого интерфейса виртуальной машины всегда должен входить в v4_cidr_blocks той подсети, к которой она подключена.
    Приоритет Security Group: Даже если подсети находятся в одной VPC, трафик между ними не пойдет, пока вы явно не разрешите его в Security Group. В правилах SG вы можете указывать либо CIDR подсетей, либо (что удобнее в Yandex Cloud) другую Security Group в качестве источника/назначения.
    Безопасность (Least Privilege): В правилах Ingress для баз данных лучше указывать не 0.0.0.0/0, а конкретный CIDR подсети, где живут ваши приложения.
  EOF
}
# ---

# --- MDB POSTGRES ---
variable "db_cluster_name" {
  type = string
}
variable "db_cluster_env" {
  type    = string
  default = "PRESTABLE"
}
variable "pg_version" {
  type    = number
  default = 16
}
variable "pg_assign_public_ip" {
  type    = bool
  default = false
}
variable "pg_config" {
  type = object({
    resources = object({
      resource_preset_id = string
      disk_type_id       = string
      disk_size          = number
    })
    max_connections = number
    web_sql_access  = bool
  })
  default = {
    resources : {
      resource_preset_id = "b1.medium"
      disk_type_id       = "network-hdd"
      disk_size          = 10
    }
    max_connections = 70
    web_sql_access  = true
  }
}

variable "db_user" {
  type = string
}
variable "db_pwd" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_port" {
  type    = number
  default = 6432
}
variable "db_host" {
  type    = string
  default = "db"
}
variable "db_posix_locale" {
  type    = string
  default = "ru_RU.UTF-8"
}
variable "db_extensions" {
  type    = list(string)
  default = ["uuid-ossp"]
}
# ---

# --- REGISTRY ---
variable "registry_name" {
  type    = string
  default = "app-registry"
}
# ---
