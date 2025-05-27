# Terraform EKS Environment CI/CD Pipeline

이 프로젝트는 Terraform을 사용하여 AWS EKS 클러스터를 프로비저닝하고, Helmfile을 통해 클러스터 내 컴포넌트를 자동으로 배포하는 인프라 관리 솔루션입니다.

## 프로젝트 구조

```
terraform-eks-environment-cicd-pipeline/
├── eks-config/                  # Helmfile 기반 컴포넌트 배포 구성
│   ├── helmfile.yaml            # 루트 Helmfile
│   ├── helmfile/                # 컴포넌트별 Helmfile
│   └── values/                  # 컴포넌트별 values 파일
├── terraform/                   # Terraform 코드
│   ├── environments/            # 환경별 설정
│   │   ├── eks/                 # EKS 환경 설정
│   │   ├── ec2/                 # EC2 환경 설정
│   │   ├── alb/                 # ALB 환경 설정
│   │   └── cloudfront/          # CloudFront 환경 설정
│   └── modules/                 # 재사용 가능한 모듈
│       ├── eks/                 # EKS 클러스터 모듈
│       ├── ec2/                 # EC2 인스턴스 모듈
│       ├── alb/                 # ALB 모듈
│       └── cloudfront/          # CloudFront 모듈
└── scripts/                     # 유틸리티 스크립트
```

## 주요 기능

1. **Terraform으로 인프라 프로비저닝**
   - EKS 클러스터 (v1.31)
   - 필요한 네트워킹 리소스
   - EC2, ALB, CloudFront 등 추가 리소스

2. **Helmfile로 EKS 컴포넌트 배포**
   - ArgoCD
   - Fluentd
   - Istio (Ingress 포함)
   - Metrics Server
   - AWS Load Balancer Controller

## 시작하기

### 사전 요구사항

- AWS CLI 구성
- Terraform v1.0.0+
- kubectl
- helm v3+
- helmfile

### EKS 클러스터 배포

```bash
cd terraform/environments/eks
terraform init
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars
```

### EKS 컴포넌트 배포

```bash
# kubeconfig 설정
aws eks update-kubeconfig --name <cluster-name> --region ap-northeast-2

# Helm 저장소 추가
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add fluent https://fluent.github.io/helm-charts
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Helmfile로 컴포넌트 배포
cd eks-config
helmfile apply
```

## 환경 설정

- `terraform/environments/eks/test.tfvars`: EKS 클러스터 설정
- `eks-config/values/`: 각 컴포넌트별 설정 값

## 추가 리소스 배포

EC2, ALB, CloudFront 등의 추가 리소스는 각 환경 디렉토리에서 배포할 수 있습니다:

```bash
cd terraform/environments/ec2
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```