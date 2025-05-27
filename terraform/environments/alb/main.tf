module "alb" {
  source = "../../modules/alb"

  project_name        = var.project_name   
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  target_instance_ids = var.target_instance_ids
  security_group_ids  = var.security_group_ids
  certificate_arn     = var.certificate_arn
  enable_https        = var.enable_https
  environment         = var.environment
  tags                = var.tags
}