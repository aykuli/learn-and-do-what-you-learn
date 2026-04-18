stack {
  name        = "vault"
  description = "vault"
}

generate_hcl "main.tf" {
  content {
    terraform {}
    provider "vault" {
      address         = var.vault_address
      skip_tls_verify = var.skip_tls_verify
      token           = var.token
    }
    data "vault_generic_secret" "vault_ex" {
      path = var.secrets_path
    }
    output "vault_info" {
      value = "${nonsensitive(data.vault_generic_secret.vault_ex.data[var.key_name])}"
    }
  }
}

generate_hcl "variables.tf" {
  content {
    variable "vault_address" {
      type    = string
      default = "http://127.0.0.1:8200"
    }

    variable "skip_tls_verify" {
      type    = bool
      default = false
    }

    variable "token" {
      type    = string
    }

    variable "secrets_path" {
      type    = string
    }

    variable "key_name" {
      type    = string
    }    
  }
}

