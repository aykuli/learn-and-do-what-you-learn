resource "local_file" "inventory" {
  content = <<-EOT
%{ for vm in yandex_compute_instance.task3_vms ~}
${vm["name"]}:
  hosts:
    ${vm["hostname"]}:
      ansible_host: ${vm.network_interface.0.nat_ip_address == "" ? vm.network_interface.0.ip_address : vm.network_interface.0.nat_ip_address}
      ansible_user: ${var.vms.user}
      ansible_become: true
%{ endfor ~}
  EOT

  filename = "../${path.module}/../task5/playbook/inventory/prod.yml"
}

