terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.132.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
  }
  required_version = ">=1.8.4"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.default_zone
}