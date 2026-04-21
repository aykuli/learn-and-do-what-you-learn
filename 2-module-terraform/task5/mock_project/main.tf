terraform {
  required_version = ">=1.12.0"
}

output "ip-check" {
  value = {
    # ip:           var.ip,
    # ip_addresses: var.ip_addresses,
    lower_str: var.lower_str
    opposite_bools = var.choose_the_right_pill
  }
}

variable "ip" {
  type = string
  description = "ip-адрес"
  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.ip))
    error_message = "Значение IP ты ввела неправильно, посмотри свои объявления переменных в *.auto.tfvars, может опечалатась?"
  }
}

variable "ip_addresses" {
  type = list(string)
  description = "список ip-адресов"
  validation {
    condition = alltrue([
      for ip in var.ip_addresses : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "В одной из адресов есть ошибка, в какой не знаю, сама ищи."
  }
}

variable "lower_str" {
  type = string
  description = "line with only lower letters"
  validation {
    condition = length(regexall("[A-Z]", var.lower_str)) == 0
    error_message = "В царство карликов принимаются только маленькие буквы. Вам в следующее окошко."
  }
}

variable "choose_the_right_pill" {
  type = object({ blue: bool, red:  bool })
  default = {blue: true, red:  false }

  validation {
    condition = values(var.choose_the_right_pill)[0] == !values(var.choose_the_right_pill)[1]
    error_message = "Ты должен выбрать только одну таблетку - выбирай настоящее или илллюзия?"
  }
}