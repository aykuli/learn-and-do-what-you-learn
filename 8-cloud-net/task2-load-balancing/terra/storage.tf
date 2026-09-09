resource "yandex_iam_service_account" "ig-storage-support" {
  name        = "ig-storage-support"
  description = "Сервисный аккаунт для управления Instance Group и Object Storage"
}

resource "yandex_resourcemanager_folder_iam_member" "ig-storage-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig-storage-support.id}"
}

resource "yandex_iam_service_account_static_access_key" "ig-support-static-key" {
  service_account_id = yandex_iam_service_account.ig-storage-support.id
  description = "Статический ключ для Object Storage"
}

resource "yandex_storage_bucket" "ayn-bucket" {
  bucket     = "aynur-bucket-2026-09"

  access_key = yandex_iam_service_account_static_access_key.ig-support-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.ig-support-static-key.secret_key
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
}

resource "yandex_storage_object" "ayn-img" {
  access_key = yandex_iam_service_account_static_access_key.ig-support-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.ig-support-static-key.secret_key
  bucket     = yandex_storage_bucket.ayn-bucket.id
  key        = "${path.module}/assets/cat.jpg"
  source     = "${path.module}/assets/cat.jpg"
  acl        = "public-read"
}