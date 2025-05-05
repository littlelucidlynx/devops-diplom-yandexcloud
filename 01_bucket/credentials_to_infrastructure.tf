// Create "local_file" for "backendConf"
resource "local_file" "backend-cfg" {
  content  = <<EOT
bucket = "${yandex_storage_bucket.cloud_bucket.bucket}"
access_key = "${yandex_iam_service_account_static_access_key.sa_key.access_key}"
secret_key = "${yandex_iam_service_account_static_access_key.sa_key.secret_key}"
EOT
  filename = "../02_infrastructure/backend.auto.tfvars"
}

// Create "local_file" for "personal"
resource "local_file" "personal-cfg" {
  content  = <<EOT
yc_token = "${var.yc_token}"
yc_cloud_id  = "${var.yc_cloud_id}"
yc_folder_id = "${var.yc_folder_id}"
service_account_id = "${yandex_iam_service_account.cloud-svc.id}"
EOT
  filename = "../02_infrastructure/personal.auto.tfvars"
}