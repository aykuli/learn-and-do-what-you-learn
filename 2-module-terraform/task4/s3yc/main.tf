module "s3" {
  source = "git::https://github.com/terraform-yc-modules/terraform-yc-s3.git?ref=v1.0.4"

  bucket_name = var.bucket

  versioning = {
    enabled = true
  }
}