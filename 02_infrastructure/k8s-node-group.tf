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