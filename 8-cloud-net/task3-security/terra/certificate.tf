resource "yandex_cm_certificate" "mmd-sert" {
  name    = "mmd-sert"
  domains = ["mymeddata.ru"]

  managed {
    challenge_type = "DNS_CNAME"
  }
}