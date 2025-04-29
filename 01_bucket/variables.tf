# Облачные переменные
/*
# Путь к открытому ключу для подключения к yandex cloud
variable "yc_ssh_key_path" {
  type        = string
}
*/
# Токен для подключения к yandex cloud
variable "yc_token" {
  type        = string
}

# ID облака
variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

# ID папки
variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

# Зона по умолчанию
variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

###

# Имя сервисного аккаунта
variable "service_account_name" {
  type        = string
  default     = "cloud-svc"
  description = "Сервисный аккаунт для управления облачной инфраструктурой"
}
/*
# Роль для управления облаком
variable "cloud_role" {
  type        = string
  default     = "editor"
}

# Роль для управления хранилищем
variable "storage_role" {
  type        = string
  default     = "storage.admin"
}
*/
# Имя s3-бакета
variable "bucket_name" {
  type        = string
  default     = "cloud-bucket"
}

# Название реестра
variable "registry_name" {
  type        = string
  default     = "cloud-registry"
}