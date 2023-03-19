provider "aws" {
  profile = var.profile
  region  = var.region
}

module "vpc" {
  source                  = "../../modules/vpc"
  cidr_blocks             = "10.0.0.0/16"
  cidr_blocks_defualt     = "0.0.0.0/0"
  public_cidr_blocks      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidr_blocks     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24"]
  availability_zones      = ["us-east-1a", "us-east-1b"]
  map_public_ip_on_launch = true
  appname                 = "web"
  env                     = "development"
}

module "instances" {
  source        = "../../modules/instances"
  instance_type = "t2.micro"
  key_name      = "allPurposeVirginia"
  name_prefix   = ["web", "app", "data"]
  appname       = module.vpc.appname
  env           = module.vpc.env
  #vpc_id                 = module.vpc.vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  private_subnet_ids     = module.vpc.private_subnet_ids
  security_group_id      = module.vpc.security_group_id
  private_instance_count = module.vpc.private_cidr_blocks
  public_instance_count  = module.vpc.public_cidr_blocks
}

# module "loadbalancer" {
#   source   = "../../modules/load-balancer"
#   internal = "false"
#   type     = "network" #"application" "network"
#   tags = {
#     Owner = "dev-one"
#   }
#   appname                = module.vpc.appname
#   env                    = module.vpc.env
#   security_group_id      = module.vpc.security_group_id
#   subnets                = module.vpc.private_subnet_ids
#   vpc_id                 = module.vpc.vpc_id
#   autoscaling_group_name = module.autoscaling.autoscaling_group_name
#   vpc_public = module.vpc.public_subnet_ids
# }
