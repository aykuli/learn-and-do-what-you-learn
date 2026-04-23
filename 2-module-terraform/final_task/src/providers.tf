terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "> 0.9"
    }
  }
  required_version = ">= 1.3.0"
}

resource "yandex_resourcemanager_folder" "final_task" {
  cloud_id = var.cloud_id
  name     = var.folder.name
  labels   = var.folder.labels
}

locals {
  folder_id = yandex_resourcemanager_folder.final_task.id
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  zone                     = var.default_zone
  folder_id                = local.folder_id
  service_account_key_file = file(var.keys_path)
}