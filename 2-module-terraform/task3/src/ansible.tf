variable "web_provision" {
  type        = bool
  default     = true
  description = "ansible provision switch variable"
}

# https://registry.terraform.io/providers/hashicorp/null/latest/docs/guides/terraform-migration
# built-in terraform_data managed resource
#  |---- The hashicorp/null provider is no longer required to be downloaded and installed.
#  |---- Resource replacement trigger configuration supports any value type.
#  |---- Optional data storage.

resource "terraform_data" "web_hosts_provision" {
  count = var.web_provision == true ? 1 : 0
  depends_on = [ yandex_compute_instance.web, yandex_compute_instance.bastion ]

  # Добавление ПРИВАТНОГО ssh ключа в ssh-agent
  provisioner "local-exec" {
    command    = "eval $(ssh-agent) && cat ~/.ssh/id_rsa | ssh-add -"
    on_failure = continue
  }

  # Run ansible-playbook
  provisioner "local-exec" {
    # without secrets
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${abspath(path.module)}/for.ini ${abspath(path.module)}/test.yml"

    on_failure  = continue
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
  }

  # This is the terraform_data version of triggers
  # Trigger if inventory file content changes
  triggers_replace = {
    inventory_hash = local_file.hosts_templatefile.content
    always_run      = "${timestamp()}" 
  }
}