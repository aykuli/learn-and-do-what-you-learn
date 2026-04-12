locals {
  vm_web_ssh_user = "${can(regex("^ubuntu", var.vm_web_instance.image_family)) ? "ubuntu" : var.vm_web_instance.metadata.ssh_user}:${var.vms_ssh_root_key}"
  vm_db_ssh_user = "${can(regex("^ubuntu", var.vm_db_instance.image_family)) ? "ubuntu" : var.vm_db_instance.metadata.ssh_user}:${var.vms_ssh_root_key}"
}