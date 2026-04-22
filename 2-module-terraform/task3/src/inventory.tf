#  inventory-файл для ansible
resource "local_file" "hosts_templatefile" {
  content = templatefile("${path.module}/hosts.tftpl",
    {
      vms = [
        { webservers: yandex_compute_instance.web },
        { databases:  [for _, vm in yandex_compute_instance.db : vm ] },
        { storage:    [yandex_compute_instance.storage] },
        { bastion:    yandex_compute_instance.bastion }
      ]
    }
  )

  filename = "${abspath(path.module)}/hosts.ini"
}

resource "local_file" "hosts_for" {
  content =  <<-EOT
  %{if length(yandex_compute_instance.web) > 0}
  [webservers]
  %{for i in yandex_compute_instance.web }
  %{if length(yandex_compute_instance.bastion) > 0}
  ${i["name"]}   ansible_host=${i["network_interface"][0]["ip_address"]}
  %{else}
  ${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]}
  %{endif}
  %{endfor}
  %{endif}
  %{if length(yandex_compute_instance.bastion) > 0}
  [bastion]
  %{for i in yandex_compute_instance.bastion }
  ${i["name"]}   ansible_host=${i["network_interface"][0]["nat_ip_address"]}

  [all:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q ubuntu@${i["network_interface"][0]["nat_ip_address"]}"'
  %{endfor}
  %{endif}
  EOT
  filename = "${abspath(path.module)}/for.ini"
}



locals {
  instances_yaml= concat(
    yandex_compute_instance.web,                     #       already list
    [for _, vm in yandex_compute_instance.db : vm ], #        map -> list
    [yandex_compute_instance.storage],                # single obj -> list
    yandex_compute_instance.bastion
  )
}

resource "local_file" "hosts_yaml" {
  content =  <<-EOT
  all:
    hosts:
    %{ for vm in local.instances_yaml ~}
  ${vm["name"]}:
        ansible_host: ${vm.network_interface.0.nat_ip_address == "" ? vm.network_interface.0.ip_address : vm.network_interface.0.nat_ip_address}
        ansible_user: ubuntu
    %{ endfor ~}
  EOT
  filename = "${abspath(path.module)}/hosts.yaml"
}

resource "local_file" "task8" {
    content = templatefile("${path.module}/task8.tftpl",
      { webservers: yandex_compute_instance.web }
    )

  filename = "${abspath(path.module)}/task8.ini"
}