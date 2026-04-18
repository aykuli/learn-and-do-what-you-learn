stack {
  name        = "vpc"
  description = "vpc"
}

generate_hcl "main.tf" {
  content {
    module "vpc_dev" {
      source    = "../modules/vpc"
      folder_id = var.folder_id
      env_name  = var.vpc_env
      subnets   = var.dev_subnets
    }

    module "vpc_prod" {
      source    = "../modules/vpc"
      folder_id = var.folder_id
      env_name  = var.vpc_env_prod
      subnets   = var.prod_subnets
    }
  }
}

generate_hcl "outputs.tf" {
  content {
    output "prod_subnets" {
      value = module.vpc_prod.subnets
    }
  }
}


