provider "aws" {
  region = var.region
  profile = var.profile 
}

# ------------------------------------------------------------------------
#  EKS Cluster(eks-blue) 생성 
# ------------------------------------------------------------------------
# EKS Cluster(eks-blue) 생성
module "eks" {
  source = "../../modules/eks"

  region                          = var.region
  profile                         = var.profile 
  project_name                    = var.project_name
  env                             = var.env 
  eks_version                     = var.eks_version
  vpc_id                          = var.vpc_id
  eks_additional_sg_ids           = var.eks_additional_sg_ids
  eks_node_sg_ids                 = var.eks_node_sg_ids
  eks_addon_versions              = var.eks_addon_versions 
  eks_node_name_info              = var.eks_node_name_info
  eks_nodegroup_info              = var.eks_nodegroup_info
  lt_keypair_name                 = var.lt_keypair_name
  workbench_sg_id                 = var.workbench_sg_id
  lt_resource_tags                = var.lt_resource_tags
  jenkins_ec2_arn                 = ""
  //jenkins_ec2_arn                 = var.jenkins_ec2_arn 
}
