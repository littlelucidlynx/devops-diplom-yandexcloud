# Кластер Kubernetes

# Этот ресурс создает региональный кластер Kubernetes с мастер-узлами в разных зонах доступности
resource "yandex_kubernetes_cluster" "regional_cluster" {
  name        = "regional-k8s-cluster"
  description = "Regional Kubernetes cluster"
  network_id  = yandex_vpc_network.network.id

  master {
    regional {
      region = "ru-central1"
      dynamic "location" {
        for_each = yandex_vpc_subnet.public_subnets
        content {
          zone      = location.value.zone
          subnet_id = location.value.id
        }
      }
    }
    version   = "1.31"
    public_ip = true
  }

  service_account_id      = yandex_iam_service_account.k8s-svc.id
  node_service_account_id = yandex_iam_service_account.k8s-svc.id
  kms_provider {
    key_id = yandex_kms_symmetric_key.bucket_key.id
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.editor,
    yandex_resourcemanager_folder_iam_binding.k8s_agent,
    yandex_resourcemanager_folder_iam_binding.vpc_admin,
    yandex_resourcemanager_folder_iam_binding.kms_access
  ]
}