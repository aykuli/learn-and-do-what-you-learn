output "vms" {
  value = [ for vm in concat(
    yandex_compute_instance.web,                     #       already list
    [for _, vm in yandex_compute_instance.db : vm ], #        map -> list
    [yandex_compute_instance.storage]                # single obj -> list
  ) : {
    name: vm.name,
    id:   vm.id,
    fqdn: vm.fqdn
  }]
}