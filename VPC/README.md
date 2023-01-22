module "example_module" {
  source = "./path/to/module"

  availability_zones = var.availability_zones
  region = var.region
}


terraform plan -target module.VPC_module