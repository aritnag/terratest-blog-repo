data "aws_caller_identity" "current" {}

module "alb" {
  source = "../../modules/alb"

  env_name   = var.env_name
  vpc_id     = var.vpc_id
  sg_id      = module.ecs.sg_id
  subnet_ids = data.aws_subnets.blogdemo_vpc_subnets.ids
  providers = {
    aws = aws
  }
}
module "ecs" {
  source                  = "../../modules/ecs"
  env_name                = var.env_name
  machine_types           = var.machine_types
  aws_region              = var.aws_region
  blogdemo_ecr_image      = var.blogdemo_ecr_image
  vpc_id                  = var.vpc_id
  account_id              = data.aws_caller_identity.current.account_id
  subnet_ids              = data.aws_subnets.blogdemo_vpc_subnets.ids
  aws_lb_target_group_arn = module.alb.aws_lb_target_group_arn
  desired_instance_count  = var.desired_instance_count
  desired_service_count   = var.desired_service_count
  rds_external_secret     = var.rds_external_secret
  rds_endpoint = var.rds_endpoint
}




module "route53" {
  source = "../../modules/route53"

  env_name        = var.env_name
  route53_zone_id = var.route53_zone_id
  route53_domain  = var.route53_domain
  lb_dns_name     = module.alb.lb_dns_name
  app_name        = var.app_name
}