# output "vms" {
#   value = [ for vm in yandex_compute_instance.vms : {
#     name: vm.name,
#     id:   vm.id,
#     fqdn: vm.fqdn
#   }]
# }
# output "all" {
#   value = yandex_compute_instance.vms
# }
output "master_public_ip" {
  value       = yandex_compute_instance.master.network_interface.0.nat_ip_address
  description = "Публичный IP мастера для подключения по SSH"
}

output "worker_public_ips" {
  value       = yandex_compute_instance.workers.*.network_interface.0.nat_ip_address
  description = "Публичные IP воркеров"
}
