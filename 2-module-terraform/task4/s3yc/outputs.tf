output "info" {
  value = {
    bucket_domain_name:               module.s3.bucket_domain_name
    bucket_name:                      module.s3.bucket_name
    cm_certificate_id:                module.s3.cm_certificate_id
    website_domain:                   module.s3.website_domain
    website_endpoint:                 module.s3.website_endpoint
  }
}