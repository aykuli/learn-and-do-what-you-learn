# terraform {
#   required_version = ">=1.12.0"
  
#   backend "s3" {
#     bucket  = "ayn-terra"
#     key     = "2-module-terraform/task4/src/terraform.tfstate"
#     region  = "ru-central1"
    
#     # Встроенный механизм блокировок (Terraform >= 1.6)
#     # Не требует отдельной базы данных!
#     use_lockfile = true
    
#     endpoints = { s3 = "https://storage.yandexcloud.net" }
    
#     skip_region_validation      = true
#     skip_credentials_validation = true
#     skip_requesting_account_id  = true
#     skip_s3_checksum            = true
#   }
# }