# --- PROVIDERS ---
variable "cloud_id" {
  type = string
}
variable "folder" {
  type = object({
    name   = string
    labels = map(string)
  })
  default = {
    name = "terraform-final"
    labels = {
      "tutor":          "Elisey Ilin"
      "tutor2":         "Eugene Mysyakov"
      "learn_platform": "netology"
      "program":        "DevOps"
      "group":          "SHDEVOPS-29"
      "learner":        "Aynur Shauerman"
    }
  }
  description = "Folder for learning purpose"
}
variable "keys_path" {
  type = string
}
variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}
# ---

# --- VPC ---
variable "vpc" {
  type = object({
    network_name   = string
    subnet_name    = string
    v4_cidr_blocks = list(string)

    sg_name        = string
  })
  default = {
    network_name   = "ayn-netw"
    subnet_name    = "ayn-subn"
    v4_cidr_blocks = [ "10.2.0.0/16" ]
  }
}

variable "sg" {
  type = object({
    name        = string
    description = string
    ingress_rules = list(object({
      protocol = string
      v4_cidr  = list(string)
      port     = number
    }))
    egress_rules = list(object({
      protocol = string
      v4_cidr  = list(string)
      port     = number
    }))
  })
  default = {
    name = "ayn_sg"
    description = "22, 80, 443 ports configs"
    ingress_rules = []
    egress_rules  = []
  }
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

