### cloud vars

# Токен для подключения к yandex cloud
variable "yc_token" {
  type        = string
}

# ID облака
variable "yc_cloud_id" {
  type        = string
}

# ID папки
variable "yc_folder_id" {
  type        = string
}

# Зона по умолчанию
variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
}

# ID сервисного аккаунта для бакета
variable "service_account_id" {
  type        = string
}

### k8s variables

# Имя сервисного аккаунта для кластера Kubernetes
variable "service_account_name" {
  type        = string
  default     = "k8s-svc"
  description = "Сервисный аккаунт для кластера Kubernetes"
}

# Путь до конфиг-файла
variable "kube_config" {
  type        = string
  default     = "/Users/eurus/.kube/config"
}

### node group vars

# Параметры шаблона для группы нод
variable "node_group_vm" {
  type = list(object({
    cores               = number
    memory              = number
    core_fraction       = number
    disk_size           = number
    disk_type           = string
    container_runtime   = string
    preemptible         = bool
    nat                 = bool
    default_zone        = string
    platform_id         = string
    scale_count_initial = number
    scale_count_min     = number
    scale_count_max     = number
  }))
  default = [{
      cores               = 2
      memory              = 2
      core_fraction       = 20
      disk_size           = 64
      disk_type           = "network-hdd"
      container_runtime   = "containerd"
      preemptible         = true
      nat                 = true
      default_zone        = "ru-central1-a"
      platform_id         = "standard-v3"
      scale_count_initial = 1
      scale_count_min     = 1
      scale_count_max     = 2
            }]
}