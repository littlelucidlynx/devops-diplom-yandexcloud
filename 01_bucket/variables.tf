# Облачные переменные

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

# Имя s3-бакета
variable "bucket_name" {
  type        = string
  default     = "cloud-bucket"
}