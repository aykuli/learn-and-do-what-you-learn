locals {
  vm_web_name = "${var.vms_resources.web.name}-${data.yandex_compute_image.ubuntu.family}"
  vm_db_name = "${var.vms_resources.db.name}-${data.yandex_compute_image.ubuntu.family}"
}