# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "dns33ib75ojj5ki3bstk/mymeddata.ru./SOA"
resource "yandex_dns_recordset" "rs_soa" {
  data        = ["ns1.yandexcloud.net. mx.cloud.yandex.net. 1 10800 900 604800 900"]
  description = null
  name        = "mymeddata.ru."
  ttl         = 3600
  type        = "SOA"
  zone_id     = "dns33ib75ojj5ki3bstk"
}

# __generated__ by Terraform from "dns33ib75ojj5ki3bstk/mymeddata.ru./NS"
resource "yandex_dns_recordset" "rs_ns" {
  data        = ["ns1.yandexcloud.net.", "ns2.yandexcloud.net."]
  description = null
  name        = "mymeddata.ru."
  ttl         = 3600
  type        = "NS"
  zone_id     = "dns33ib75ojj5ki3bstk"
}

# __generated__ by Terraform from "dns33ib75ojj5ki3bstk/mymeddata.ru./A"
resource "yandex_dns_recordset" "rs_a" {
  data        = ["62.84.119.20"]
  description = "итоговое задание 2го модуля Дувопс"
  name        = "mymeddata.ru."
  ttl         = 600
  type        = "A"
  zone_id     = "dns33ib75ojj5ki3bstk"
}

# __generated__ by Terraform from "dns33ib75ojj5ki3bstk"
resource "yandex_dns_zone" "mymeddataru" {
  deletion_protection = false
  description         = "для целей финального задания юзаю какой-то своё доменное имя, оно ничего не означает"
  folder_id           = "b1gk3l1bd4nvn0fi0fvj"
  labels              = {}
  name                = "mymeddataru"
  public              = true
  zone                = "mymeddata.ru."
}
