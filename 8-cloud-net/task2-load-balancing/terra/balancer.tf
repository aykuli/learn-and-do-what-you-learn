resource "yandex_lb_network_load_balancer" "ayn-net-balancer" {
  folder_id = var.folder_id

  name      = "ayn-network-balancer"
  type      = "external"

  listener {
    name = "ayn-http-balancer-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.ayn-ig.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}