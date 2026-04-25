output "vms" {
  value = {
    marketings_ips: module.marketing_vm.external_ip_address,
    # analytics_ips:  module.analytics_vm.external_ip_address
  }
}