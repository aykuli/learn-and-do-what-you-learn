# terraform {
  # backend "s3" {
  #   endpoints = {s3="https://storage.yandexcloud.net"}
  #   bucket   = "tfstate-store"
  #   key      = "final-task/terraform.tfstate"

  #   region                      = "ru-central1"
  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  #   skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
  #   skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  # }
# }