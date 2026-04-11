
provider "docker" {
  host = "ssh://ubuntu@${yandex_compute_instance.aynur_vm_from_terra_resource.network_interface.0.nat_ip_address}:22"
  # REQUIRED: This ignores the "Unknown Host Key" error. 
  # Without this, Terraform will fail because it cannot interactively ask you to verify the host.
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

resource "docker_image" "mysql" {
  name         = "mysql:8"
  keep_locally = false
}

resource "docker_container" "mysql" {
  image = docker_image.mysql.image_id
  name  = "tutorial"
  ports {
    internal = 3306
    external = 3306
  }
  env = [
     "MYSQL_ROOT_PASSWORD=${random_password.random_string.result}",
     "MYSQL_DATABASE=${var.mysql_database}",
     "MYSQL_USER=${var.mysql_user}",
     "MYSQL_PASSWORD=${random_password.random_string.result}",
     "MYSQL_ROOT_HOST=%"
  ]
}