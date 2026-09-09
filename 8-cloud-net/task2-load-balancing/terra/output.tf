output "network_load_balancer_ip-listener" {
  value = yandex_lb_network_load_balancer.ayn-net-balancer.listener
  # value = yandex_lb_network_load_balancer.nlb.listener[0].external_address_spec[0].address
}

# output "yandex_alb_backend_group" {
#   value = yandex_alb_backend_group.ayn-app-balancer.http_backend
# }