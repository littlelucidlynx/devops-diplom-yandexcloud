terraform {
  required_providers {
    yandex    = {
      source  = "yandex-cloud/yandex"
      version = "0.132.0"
    }
    local     = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
  required_version = ">=1.8.4"
}

provider "yandex" {
  cloud_id                  = var.cloud_id
  folder_id                 = var.folder_id
  zone                      = var.default_zone
  service_account_key_file  = file(var.yc_ssh_key_path)
}