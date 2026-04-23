# resource "yandex_iam_service_account" "final_task_sa" {
#   name      = var.service_account_name
#   folder_id = local.folder_id
# }
# resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
#   role       = "storage.admin"
#   member     = "serviceAccount:${yandex_iam_service_account.storage_admin.id}"
#   folder_id  = local.folder_id
#   depends_on = [yandex_iam_service_account_static_access_key.storage_admin]
# }
# resource "yandex_iam_service_account_static_access_key" "final_task_sa_secrets" {
#   service_account_id = yandex_iam_service_account.final_task_sa.id
#   description        = "Static access key for Object storage admin service account."
# }