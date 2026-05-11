output "ips" {
  value = {
    clickhouse: {
      hostname: yandex_compute_instance.task3_vms[0].hostname,
      ip: yandex_compute_instance.task3_vms[0].network_interface[0].nat_ip_address,
    }
    lighthouse:{
      hostname: yandex_compute_instance.task3_vms[1].hostname,
      ip: yandex_compute_instance.task3_vms[1].network_interface[0].nat_ip_address,
    },
    vector: {
      hostname: yandex_compute_instance.task3_vms[2].hostname,
      ip: yandex_compute_instance.task3_vms[2].network_interface[0].nat_ip_address,
    }
  }
}