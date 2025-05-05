# Создание KMS-ключа для бакета

# Этот ресурс создает симметричный ключ KMS, который будет использоваться для шифрования содержимого бакета
resource "yandex_kms_symmetric_key" "bucket_key" {
  name              = "bucket-encryption-key"
  description       = "KMS key for encrypting bucket content"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" # 365 дней
}

# Создание статического ключа доступа

# Этот ресурс создает статический ключ доступа для сервисного аккаунта, который будет использоваться для доступа к объектному хранилищу
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = var.service_account_id
  description        = "static access key for object storage"
}

# Сеть и подсети

# Этот ресурс создает виртуальную частную сеть (VPC) и подсети в разных зонах доступности.
resource "yandex_vpc_network" "network" {
  name = "network"
}

# Создание публичных подсетей в трех зонах доступности.
resource "yandex_vpc_subnet" "public_subnets" {
  count = 3
  name           = "public-subnet-${count.index}"
  zone           = "ru-central1-${element(["a", "b", "d"], count.index)}"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [cidrsubnet("10.1.0.0/16", 8, count.index)]
}

# Сервисный аккаунт для Kubernetes

# Этот ресурс создает сервисный аккаунт для Kubernetes и назначает ему необходимые роли

resource "yandex_iam_service_account" "k8s-svc" {
  name        = var.service_account_name
  description = "Сервисный аккаунт для кластера Kubernetes"
}

# Назначение роли "editor" сервисному аккаунту.
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s-svc.id}"]
}

# Назначение роли "k8s.clusters.agent" сервисному аккаунту.
resource "yandex_resourcemanager_folder_iam_binding" "k8s_agent" {
  folder_id = var.yc_folder_id
  role      = "k8s.clusters.agent"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s-svc.id}"]
}

# Назначение роли "vpc.publicAdmin" сервисному аккаунту.
resource "yandex_resourcemanager_folder_iam_binding" "vpc_admin" {
  folder_id = var.yc_folder_id
  role      = "vpc.publicAdmin"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s-svc.id}"]
}

# Назначение роли "kms.keys.encrypterDecrypter" сервисному аккаунту.
resource "yandex_resourcemanager_folder_iam_binding" "kms_access" {
  folder_id = var.yc_folder_id
  role      = "kms.keys.encrypterDecrypter"
  members   = ["serviceAccount:${yandex_iam_service_account.k8s-svc.id}"]
}

# Назначение роли "k8s.admin" сервисному аккаунту.
resource "yandex_resourcemanager_folder_iam_binding" "k8s_admin" {
  folder_id = var.yc_folder_id
  role      = "k8s.admin"
  members   = [
    "serviceAccount:${yandex_iam_service_account.k8s-svc.id}"
  ]
}

# Создаем ключ сервисного аккаунта

# Этот ресурс создает ключ для сервисного аккаунта, который будет использоваться для аутентификации в Kubernetes
resource "yandex_iam_service_account_key" "k8s-svc-key" {
  service_account_id = yandex_iam_service_account.k8s-svc.id
  description        = "K8S SA key for Terraform"
  key_algorithm      = "RSA_4096"
}

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

# Группы узлов Kubernetes

# Этот ресурс создает группы узлов Kubernetes с автоматическим масштабированием в разных зонах доступности
resource "yandex_kubernetes_node_group" "node_groups" {
  for_each = {
    a = 0
    b = 1
    d = 2 
  }

  cluster_id = yandex_kubernetes_cluster.regional_cluster.id
  name       = "autoscaling-node-group-${each.key}"

  instance_template {
    platform_id = var.node_group_vm[0].platform_id
    resources {
      cores         = var.node_group_vm[0].cores
      core_fraction = var.node_group_vm[0].core_fraction
      memory        = var.node_group_vm[0].memory
    }

    boot_disk {
      type = var.node_group_vm[0].disk_type
      size = var.node_group_vm[0].disk_size
    }

    container_runtime {
      type = var.node_group_vm[0].container_runtime
    }

    scheduling_policy {
      preemptible = var.node_group_vm[0].preemptible
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.public_subnets[each.value].id]
      nat        = var.node_group_vm[0].nat
    }
  }

  scale_policy {
    auto_scale {
      min     = var.node_group_vm[0].scale_count_min
      max     = var.node_group_vm[0].scale_count_max
      initial = var.node_group_vm[0].scale_count_initial
    }
  }

  allocation_policy {
    location {
      zone = yandex_vpc_subnet.public_subnets[each.value].zone
    }
  }

  depends_on = [yandex_kubernetes_cluster.regional_cluster]
}

# Настройка kubectl

# Этот ресурс генерирует локальный kubeconfig файл
#provider "local" {}

resource "local_file" "kubeconfig" {
  filename         = var.kube_config
  content          = templatefile("${path.module}/kubeconfig.tpl", {
    endpoint       = yandex_kubernetes_cluster.regional_cluster.master[0].external_v4_endpoint
    cluster_ca     = base64encode(yandex_kubernetes_cluster.regional_cluster.master[0].cluster_ca_certificate)
    k8s_cluster_id = yandex_kubernetes_cluster.regional_cluster.id
  })
}