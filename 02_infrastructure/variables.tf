###cloud vars
variable "yc_token" {
  type        = string
}

variable "yc_cloud_id" {
  type        = string
}

variable "yc_folder_id" {
  type        = string
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
}

/*
variable "default_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
}
*/

variable "service_account_id" {
  type        = string
}

variable "kube_config" {
  type        = string
  default     = "/Users/eurus/.kube/config"
}

# node group vars

# Параметры шаблона для группы нод
variable "node_group_vm" {
  type = list(object({
    cores               = number
    memory              = number
    core_fraction       = number
    disk_size           = number
    disk_type           = string
    preemptible         = bool
    nat                 = bool
    default_zone        = string
    platform_id         = string
    scale_count_initial = number
    scale_count_min     = number
    scale_count_max     = number
  }))
  default = [{
      cores         = 2
      memory        = 4
      core_fraction = 20
      disk_size     = 64
      disk_type     = "network-hdd"
      preemptible   = true
      nat           = true
      default_zone  = "ru-central1-a"
      platform_id   = "standard-v3"
      scale_count_initial = 1
      scale_count_min     = 1
      scale_count_max     = 2
            }]
}