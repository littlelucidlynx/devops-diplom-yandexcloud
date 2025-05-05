# Сеть и подсети

# Этот ресурс создает виртуальную частную сеть (VPC) и подсети в разных зонах доступности.
resource "yandex_vpc_network" "network" {
  name = "network"
}

# Создание публичных подсетей в трех зонах доступности.
resource "yandex_vpc_subnet" "public_subnets" {
  count          = 3
  name           = "public-subnet-${count.index}"
  zone           = "ru-central1-${element(["a", "b", "d"], count.index)}"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [cidrsubnet("10.1.0.0/16", 8, count.index)]
}