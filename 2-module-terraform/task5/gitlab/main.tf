resource "yandex_vpc_network" "gl_netwok" {
  name = var.netw_name
}
resource "yandex_vpc_subnet" "gl_subnet" {
  name           = var.subn_name
  folder_id      = var.folder_id
  v4_cidr_blocks = var.v4_cidr_blocks
  network_id     = yandex_vpc_network.gl_netwok.id
}

# @see https://yandex.cloud/ru/docs/terraform/resources/gitlab_instance
resource "yandex_gitlab_instance" "ayngitlab" {
  name               = var.gl_config.name
  resource_preset_id = var.gl_config.resource_preset_id
  disk_size          = var.gl_config.disk_size
  
  admin_login        = var.gl_config.admin_login
  admin_email        = var.gl_config.admin_email
  domain             = var.gl_config.domain
  approval_rules_id  = var.gl_config.approval_rules_id


  subnet_id = yandex_vpc_subnet.gl_subnet.id
  backup_retain_period_days = var.gl_config.backup_retain_period_days
}
