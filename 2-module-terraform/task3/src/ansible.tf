#  inventory-файл для ansible
resource "local_file" "hosts_templatefile" {
  content = templatefile("${path.module}/hosts.tftpl",
    {
      vms = [
        { webservers: yandex_compute_instance.web },
        { databases:  [for _, vm in yandex_compute_instance.db : vm ] },
        { storage:    [yandex_compute_instance.storage] }
      ]
    }
  )

  filename = "${abspath(path.module)}/hosts.ini"
}

# Этот вариант трудно редактируемый, этому варианту ставлю минус
resource "local_file" "hosts_for" {
  content =  <<-EOT
  %{if length(yandex_compute_instance.web) > 0}
  [webservers]
  %{for i in yandex_compute_instance.web }${i["name"]}  %{if i["network_interface"][0]["nat_ip_address"] != ""}   ansible_host=${i["network_interface"][0]["nat_ip_address"]}   %{endif}fqdn=${i["fqdn"]}
  %{endfor}%{endif}
  %{if length(yandex_compute_instance.db) > 0}
  [databases]
  %{for i, v in yandex_compute_instance.db }${v["name"]}   fqdn=${v["fqdn"]}
  %{endfor}
  [storage]
  ${yandex_compute_instance.storage.name}   fqdn=${yandex_compute_instance.storage.fqdn}
 
  %{endif}
  EOT
  filename = "${abspath(path.module)}/for.ini"
}



locals {
  instances_yaml= concat(
    yandex_compute_instance.web,                     #       already list
    [for _, vm in yandex_compute_instance.db : vm ], #        map -> list
    [yandex_compute_instance.storage]                # single obj -> list
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