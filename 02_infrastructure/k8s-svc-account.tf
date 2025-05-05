# Создание KMS-ключа для бакета

# Этот ресурс создает симметричный ключ KMS, который будет использоваться для шифрования содержимого бакета
resource "yandex_kms_symmetric_key" "bucket_key" {
  name              = "bucket-encryption-key"
  description       = "KMS key for encrypting bucket content"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" # 365 дней
}

# Создание статического ключа доступа

# Этот ресурс создает статический ключ доступа для сервисного аккаунта, который будет использоваться для доступа к объектному хранилищу
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = var.service_account_id
  description        = "static access key for object storage"
}

# Сервисный аккаунт для Kubernetes

# Этот ресурс создает сервисный аккаунт для Kubernetes и назначает ему необходимые роли

resource "yandex_iam_service_account" "k8s-svc" {
  name        = var.service_account_name
  description = "Сервисный аккаунт для кластера Kubernetes"
}

# Назначение роли "editor" сервисному аккаунту.
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s-svc.id}"]
}

# Назначение роли "k8s.clusters.agent" сервисному аккаунту.
resource "yandex_resourcemanager_folder_iam_binding" "k8s_agent" {
  folder_id = var.yc_folder_id
  role      = "k8s.clusters.agent"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s-svc.id}"]
}

# Назначение роли "vpc.publicAdmin" сервисному аккаунту.
resource "yandex_resourcemanager_folder_iam_binding" "vpc_admin" {
  folder_id = var.yc_folder_id
  role      = "vpc.publicAdmin"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s-svc.id}"]
}

# Назначение роли "kms.keys.encrypterDecrypter" сервисному аккаунту.
resource "yandex_resourcemanager_folder_iam_binding" "kms_access" {
  folder_id = var.yc_folder_id
  role      = "kms.keys.encrypterDecrypter"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s-svc.id}"]
}

# Назначение роли "k8s.admin" сервисному аккаунту.
resource "yandex_resourcemanager_folder_iam_binding" "k8s_admin" {
  folder_id = var.yc_folder_id
  role      = "k8s.admin"
  members   = [
    "serviceAccount:${yandex_iam_service_account.k8s-svc.id}"
  ]
}

# Создаем ключ сервисного аккаунта

# Этот ресурс создает ключ для сервисного аккаунта, который будет использоваться для аутентификации в Kubernetes
resource "yandex_iam_service_account_key" "k8s-svc-key" {
  service_account_id = yandex_iam_service_account.k8s-svc.id
  description        = "K8S SA key for Terraform"
  key_algorithm      = "RSA_4096"
}