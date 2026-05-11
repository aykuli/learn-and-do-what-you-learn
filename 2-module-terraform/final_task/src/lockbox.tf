
resource "yandex_lockbox_secret" "db_pswd" {
  folder_id = var.folder_id
  name = var.lockbox.name
}

resource "yandex_lockbox_secret_version" "v1" {
  secret_id = yandex_lockbox_secret.db_pswd.id

  dynamic "entries" {
    for_each = var.lockbox.entries

    content {
      key        = entries.value["key"]
      text_value = entries.value["text_value"]
    }
  }
}
