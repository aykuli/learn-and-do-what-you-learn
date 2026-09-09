resource "yandex_lb_network_load_balancer" "ayn-net-balancer" {
  name      = "ayn-net-balancer"
  folder_id = var.folder_id
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

# resource "yandex_alb_load_balancer" "ayn-app-lb" {
#   allocation_policy {
#     location {
#       zone_id         = "ru-central1-d"
#       subnet_id       = "fl8986f6i7t788nurc9u"
#       disable_traffic = false
#     }
#   }
#   auto_scale_policy {
#     min_zone_size = 3
#     max_size      = 3
#   }
#   folder_id = "b1gke7r8638709e69ai6"
#   log_options {
#     disable = true
#   }
#   name       = "ayn-app-lb"
#   network_id = "enpulpnurj8tq7kheika"
#   region_id  = "ru-central1"
# }


# resource "yandex_alb_backend_group" "ayn-app-balancer" {
#   name = "ayn-app-balancer"
#   http_backend {
#     name = "ayn-app-balancer"
#     weight = 1
#     port   = 80
#     target_group_ids = [yandex_compute_instance_group.ayn-ig.application_load_balancer[0].target_group_id]
    
#     load_balancing_config {
#       panic_threshold = 90
#     }    
#     healthcheck {
#       timeout             = "2s"
#       interval            = "5s"
#       healthy_threshold   = 2
#       unhealthy_threshold = 3
#       http_healthcheck {
#         path = "/"
#       }
#     }
#   }
# }
