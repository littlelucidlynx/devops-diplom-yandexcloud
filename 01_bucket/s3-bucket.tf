# s3-бакет
resource "yandex_storage_bucket" "cloud_bucket" {
  bucket     = "${var.bucket_name}-${var.yc_folder_id}"
  access_key = yandex_iam_service_account_static_access_key.sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_key.secret_key
  acl        = "private"
  force_destroy = true
}