/*
output "registry_id" {
  value = yandex_container_registry.image_registry.id
}
*/

output "bucket_name" {
  value = yandex_storage_bucket.cloud_bucket.bucket
}

output "access_key" {
  value = yandex_iam_service_account_static_access_key.sa_key.access_key
}

output "secret_key" {
  value     = yandex_iam_service_account_static_access_key.sa_key.secret_key
  sensitive = true
}

output "service_account_id" {
  value = yandex_iam_service_account.cloud-svc.id
}

output "registry_name" {
  value = yandex_container_registry.cloud_registry.name
}

output "registry_id" {
  value = yandex_container_registry.cloud_registry.id
}