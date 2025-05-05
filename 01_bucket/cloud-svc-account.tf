# Сервисный аккаунт для управления облачной инфраструктурой
resource "yandex_iam_service_account" "cloud-svc" {
  name        = var.service_account_name
  description = "Сервисный аккаунт для управления облачной инфраструктурой"
}

# Роль управления облаком
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id  = var.yc_folder_id
  role       = "editor"
  members    = [
    "serviceAccount:${yandex_iam_service_account.cloud-svc.id}"
  ]
  depends_on = [ yandex_iam_service_account.cloud-svc ]
}

# Роль управления хранилищем
resource "yandex_resourcemanager_folder_iam_binding" "storage_admin" {
  folder_id  = var.yc_folder_id
  role       = "storage.admin"
  members    = [
    "serviceAccount:${yandex_iam_service_account.cloud-svc.id}"
  ]
  depends_on = [ yandex_iam_service_account.cloud-svc ]
}

# Статический ключ доступа для сервисной у/з terraform-svc
resource "yandex_iam_service_account_static_access_key" "sa_key" {
  service_account_id = yandex_iam_service_account.cloud-svc.id
}