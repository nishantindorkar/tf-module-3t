provider "aws" {
  profile = var.profile
  region  = var.region
}

module "vpc" {
  source                  = "../../modules/vpc"
  cidr_blocks             = var.cidr_blocks
  cidr_blocks_defualt     = var.cidr_blocks_defualt
  public_cidr_blocks      = var.public_cidr_blocks
  private_cidr_blocks     = var.private_cidr_blocks
  availability_zones      = var.availability_zones
  map_public_ip_on_launch = var.map_public_ip_on_launch
  appname                 = var.appname
  env                     = var.env
  name_prefix   = ["web", "app", "data"]
}

module "instances" {
  source        = "../../modules/instances"
  instance_type = var.instance_type
  key_name      = var.key_name
  appname       = module.vpc.appname
  env           = module.vpc.env
  #vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_subnet_ids     = module.vpc.private_subnet_ids
  security_group_id      = module.vpc.security_group_id
  target-group           = module.loadbalancer.target-group
  app-target-group       = module.loadbalancer.app-target-group
  private_instance_count = module.vpc.private_cidr_blocks
  public_instance_count  = module.vpc.public_cidr_blocks
}

module "loadbalancer" {
  source   = "../../modules/load-balancer"
  internal = "false"
  type = "application"
  tags = {
    Owner = "dev-one"
  }
  appname                = module.vpc.appname
  env                    = module.vpc.env
  security_group_id      = module.vpc.security_group_id
  vpc_id                 = module.vpc.vpc_id
  #autoscaling_group_name = module.autoscaling.autoscaling_group_name
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_subnet_ids     = module.vpc.private_subnet_ids
}
