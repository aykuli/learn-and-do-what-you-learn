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

    resource "vault_generic_secret" "writing_example" {
      path = var.secrets_path

      data_json = var.writing_example != null ? jsonencode(var.writing_example) : null
    }

    output "vault_info" {
      value = "Success! The secret is written to Vault"
      # Below row is for test purpose only, in real life you should never output secrets in plain text
      # value = "${nonsensitive(data.vault_generic_secret.vault_ex.data[var.key_name])}"
    }
  }
}

generate_hcl "v_variables.tf" {
  inherit = false
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

    variable "writing_example" {
      type = map(string)
    }
  }
}

