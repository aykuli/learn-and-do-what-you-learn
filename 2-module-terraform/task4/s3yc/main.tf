module "s3" {
  source = "git::https://github.com/terraform-yc-modules/terraform-yc-s3.git"

  bucket_name = var.bucket

  versioning = {
    enabled = true
  }
}