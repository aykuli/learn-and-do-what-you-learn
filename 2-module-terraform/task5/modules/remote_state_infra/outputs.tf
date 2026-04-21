output "bucket_name" {
  description = "The name of the bucket."
  value       = yandex_storage_bucket.this.id
}

output "bucket_domain_name" {
  description = "The bucket domain name."
  value       = yandex_storage_bucket.this.bucket_domain_name
}

output "website_endpoint" {
  description = "The website endpoint."
  value       = yandex_storage_bucket.this.website_endpoint
}

output "website_domain" {
  description = "The domain of the website endpoint."
  value       = yandex_storage_bucket.this.website_domain
}

output "access_key" {
  description = "Service account secret_key."
  value       = nonsensitive(yandex_iam_service_account_static_access_key.sa-static-key.access_key)
}

output "secret_key" {
  description = "Service account secret_key."
  value       = nonsensitive(yandex_iam_service_account_static_access_key.sa-static-key.secret_key)
}