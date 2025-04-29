resource "yandex_compute_instance" "gitlab" {
  for_each = tomap({for i in var.each_vm : i.vm_name => i})
    name = each.value.vm_name  
    hostname = each.value.vm_name
  zone = var.web_default_zone
  platform_id = var.standart_platform_id

    resources {
      cores = each.value.cpu
      memory = each.value.ram
      core_fraction = each.value.core_fraction
    }
  boot_disk {
    initialize_params {
#      image_id = data.yandex_compute_image.db.image_id
      image_id = each.value.image_id
      type     = each.value.type_storage
      size     = each.value.disk_volume
    }
  }
  scheduling_policy {
    preemptible = each.value.preemptible
  }
  network_interface {
    subnet_id           = yandex_vpc_subnet.subnetwork.id
    nat                 = each.value.nat
    security_group_ids  = [yandex_vpc_security_group.security_group.id]
  }

  metadata = {
    serial-port-enable = var.serial-port-enable
    user-data          = file("./cloud-init.yml")
  }
}