provider "aws" {
  region  = "ap-northeast-2"
  profile = "2244615"
}

module "ec2" {
  source = "../../modules/ec2"

  instance_name = var.instance_name
  environment   = var.environment
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  instance_type = var.instance_type
  key_name      = var.key_name
  ami_id        = var.ami_id
  tags          = var.tags
  ingress_rules = var.ingress_rules
}