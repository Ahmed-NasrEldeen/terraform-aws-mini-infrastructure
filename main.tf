locals {
  common_tags = {
    Environment = "demo"
  }
}

module "network" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
  tags        = merge(local.common_tags, { Component = "network" })
}

module "web" {
  source        = "./modules/ec2"
  subnet_id     = module.network.public_subnet_id
  vpc_id        = module.network.vpc_id
  instance_type = var.instance_type
  tags          = merge(local.common_tags, { Component = "web", Name = "public-web" })
}