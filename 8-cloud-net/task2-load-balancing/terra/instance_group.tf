resource "yandex_compute_instance_group" "ayn-ig" {
  name               = "ayn-ig"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.ig-support.id
  
  deletion_protection = false
  
  instance_template {
    platform_id = var.vm.platform_id
    resources {
      memory = 2
      cores  = 2
      core_fraction = 20
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }
    scheduling_policy {
      preemptible = true
    }

    network_interface {
      network_id         = yandex_vpc_network.ayn-net.id
      subnet_ids         = [ yandex_vpc_subnet.ayn-subnet.id ]
      security_group_ids = [ yandex_vpc_security_group.ayn-sg.id ]
      nat = true
    }

    metadata = {
      user-data = templatefile("config.yml",{
        VM_USER = var.vm_user
        SSH_KEY = var.ssh_key,
      })
      ssh-keys = "${var.vm_user}:${var.ssh_key}"
      serial-port-enable = 1
    }
  }

  load_balancer {
    
    target_group_name = "ayn-ig-lb"
    target_group_description = "Целевая группа для Сетевого балансировщика"
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
    max_creating     = 0
    max_deleting     = 2
    startup_duration = 60
    strategy         = "proactive"
  }

  health_check {
    interval            = 5
    timeout             = 2
    unhealthy_threshold = 3
    healthy_threshold   = 2
    http_options {
      path = "/"
      port = 80
    }
  }
}