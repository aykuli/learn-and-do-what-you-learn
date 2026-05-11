output "registry" {
  value =  {
    id: yandex_container_registry.ayn_registry.id
    name: yandex_container_registry.ayn_registry.name
    registry_id: yandex_container_registry.ayn_registry.registry_id
    status: yandex_container_registry.ayn_registry.status
  }
}

output "vm" {
  value = yandex_compute_instance.web.network_interface[0].nat_ip_address
}