# Настройка kubectl

# Этот ресурс генерирует локальный kubeconfig файл на основе шаблона

resource "local_file" "kubeconfig" {
  filename = var.kube_config
  content = templatefile("${path.module}/kubeconfig.tpl", {
    endpoint       = yandex_kubernetes_cluster.regional_cluster.master[0].external_v4_endpoint
    cluster_ca     = base64encode(yandex_kubernetes_cluster.regional_cluster.master[0].cluster_ca_certificate)
    k8s_cluster_id = yandex_kubernetes_cluster.regional_cluster.id
  })
}