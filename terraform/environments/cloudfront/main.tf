module "cloudfront" {
  source = "../../modules/cloudfront"

  origin_domain_name = var.origin_domain_name
  origin_id          = var.origin_id
  origin_type        = var.origin_type
  certificate_arn    = var.certificate_arn
  domain_names       = var.domain_names
  enable_https_only  = var.enable_https_only
  price_class        = var.price_class
  environment        = var.environment
  tags               = var.tags
}