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
  name_prefix             = ["web", "app", "data"]
}

module "instances" {
  source                 = "../../modules/instances"
  instance_type          = var.instance_type
  key_name               = var.key_name
  appname                = module.vpc.appname
  env                    = module.vpc.env
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_subnet_ids     = module.vpc.private_subnet_ids
  security_group_id      = module.vpc.security_group_id
  target-group           = module.loadbalancer.target-group
  app-target-group       = module.loadbalancer.app-target-group
  private_instance_count = module.vpc.private_cidr_blocks
  public_instance_count  = module.vpc.public_cidr_blocks
  internal_lb_dns        = module.loadbalancer.internal_lb_dns
  nginx_lb_dns           = module.loadbalancer.nginx_lb_dns
}

module "loadbalancer" {
  source             = "../../modules/load-balancer"
  internal           = var.internal
  type               = var.type
  tags               = { Owner = "dev-loadbalancer" }
  appname            = module.vpc.appname
  env                = module.vpc.env
  security_group_id  = module.vpc.security_group_id
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

# module "rds" {
#   source             = "../../modules/rds"
#   appname            = module.vpc.appname
#   env                = module.vpc.env
#   rds_subnet_name    = var.rds_subnet_name
#   rds_storage        = var.rds_storage
#   rds_engine         = var.rds_engine
#   rds_engine_version = var.rds_engine_version
#   rds_instance_class = var.rds_instance_class
#   rds_db_name        = var.rds_db_name
#   rds_username       = var.rds_username
#   rds_password       = var.rds_password
#   rds_identifier     = var.rds_identifier
#   rds_storage_type   = var.rds_storage_type
#   skip_snapshot      = var.skip_snapshot
#   private_subnet_ids = module.vpc.private_subnet_ids
#   tags               = { Owner = "dev-rds" }
#   security_group_id  = module.vpc.security_group_id
# }