# resource "yandex_container_registry" "web_app_registry" {
#   name      = var.registry_name
#   folder_id = var.folder_id
# }

# resource "yandex_container_registry_iam_binding" "puller" {
#   registry_id = yandex_container_registry.web_app_registry.id
#   role        = "container-registry.images.puller"

#   members = [ "serviceAccount:${yandex}" ]
# }
# resource "yandex_iam_service_account." "name" {
# }