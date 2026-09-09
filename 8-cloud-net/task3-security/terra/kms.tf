resource "yandex_kms_symmetric_key" "aynkey" {
  default_algorithm = "AES_256"
  name              = "ayn-key"
  rotation_period   = "7"
  folder_id         = var.folder_id
}
resource "yandex_iam_service_account" "mmd-storage-support" {
  name      = "mmd-storage-support"
  folder_id = var.folder_id
}

resource "yandex_iam_service_account_static_access_key" "mmd-support-static-key" {
  service_account_id = yandex_iam_service_account.mmd-storage-support.id
}

resource "yandex_storage_bucket" "ayn-bucket" {
  bucket     = "aynur-bucket-2026-09"

  access_key = yandex_iam_service_account_static_access_key.mmd-support-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.mmd-support-static-key.secret_key
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.aynkey.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}


resource "yandex_storage_bucket" "mmd-bucket" {
  bucket = "mymeddata.ru"

  access_key = yandex_iam_service_account_static_access_key.mmd-support-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.mmd-support-static-key.secret_key
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.aynkey.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}