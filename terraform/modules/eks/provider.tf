# ------------------------------------------------------------------------
# Provider 설정 
# Terraform에서 kubernetes, helm 접근 할 수 있도록 인증 정보 제공
# Kubernetes = 2.27.0 (client-go to v0.31.0)  eks 1.31 버전과 호환: https://github.com/hashicorp/terraform-provider-kubernetes/releases/tag/v2.27.0
# ------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes" 
      #version = "~> 2.16.1"
      version = "= 2.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
  }
  
}

provider "aws" {
  region = "ap-northeast-2"
    profile = "2244615"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks-blue-auth.token
}

#Helm provider v2.0+에서는 kubernetes 블록 방식이 아닌 직접 속성 설정 방식 사용
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--region", "${var.region}",  "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}
