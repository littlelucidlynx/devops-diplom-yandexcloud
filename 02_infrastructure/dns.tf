resource "yandex_dns_zone" "littlelucidlynx" {
  name        = "littlelucidlynx"
  description = "Публичная зона для домена littlelucidlynx.ru"

  zone             = "littlelucidlynx.ru."
  public           = true
  private_networks = [yandex_vpc_network.network.id]
}

resource "yandex_dns_recordset" "domain" {
  zone_id = yandex_dns_zone.littlelucidlynx.id
  name    = "@"
  type    = "A"
  ttl     = 60
  data    = ["84.252.132.211"]
}

resource "yandex_dns_recordset" "app" {
  zone_id = yandex_dns_zone.littlelucidlynx.id
  name    = "app"
  type    = "A"
  ttl     = 60
  data    = ["84.252.132.212"]
}

resource "yandex_dns_recordset" "grafana" {
  zone_id = yandex_dns_zone.littlelucidlynx.id
  name    = "grafana"
  type    = "A"
  ttl     = 60
  data    = ["84.252.132.213"]
}