# Terraform EKS Environment CI/CD Pipeline

이 프로젝트는 Terraform을 사용하여 AWS 인프라를 프로비저닝하고, EKS 클러스터 내 컴포넌트를 자동으로 배포하는 인프라 관리 솔루션입니다.

## 프로젝트 구조

```
terraform-eks-environment-cicd-pipeline/
├── terraform/                   # Terraform 코드
│   ├── environments/            # 환경별 설정
│   │   ├── vpc/                 # VPC 환경 설정
│   │   ├── eks/                 # EKS 환경 설정
│   │   ├── ec2/                 # EC2 환경 설정
│   │   ├── alb/                 # ALB 환경 설정
│   │   └── cloudfront/          # CloudFront 환경 설정
│   └── modules/                 # 재사용 가능한 모듈
│       ├── vpc/                 # VPC 모듈
│       ├── eks/                 # EKS 클러스터 모듈
│       │   └── helm_values/     # Helm values 파일
│       │       ├── argocd/      # ArgoCD 설정
│       │       ├── fluentd/     # Fluentd 설정
│       │       └── istio/       # Istio 설정
│       ├── ec2/                 # EC2 인스턴스 모듈
│       ├── alb/                 # ALB 모듈
│       ├── cloudfront/          # CloudFront 모듈
│       └── lambda/              # Lambda 모듈
├── .gitignore                   # Git ignore 설정
└── README.md                    # 프로젝트 문서
```

## 주요 기능

1. **Terraform으로 인프라 프로비저닝**
   - VPC 및 네트워킹 리소스
   - EKS 클러스터 (v1.31)
   - EC2, ALB, CloudFront 등 추가 리소스
   - Lambda 함수

2. **EKS 클러스터 컴포넌트**
   - Cluster Autoscaler
   - Istio Service Mesh (v1.24.2)
   - ArgoCD (Helm values 포함)
   - Fluentd (커스텀 차트 포함)

## 시작하기

### 사전 요구사항

- AWS CLI 구성
- Terraform v1.0.0+
- kubectl
- helm v3+

### 배포 순서

1. **VPC 배포**
```bash
cd terraform/environments/vpc
terraform init
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars
```

2. **EKS 클러스터 배포**
```bash
cd terraform/environments/eks
terraform init
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars
```

3. **추가 리소스 배포**
```bash
# EC2
cd terraform/environments/ec2
terraform init
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars

# ALB
cd terraform/environments/alb
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

# CloudFront
cd terraform/environments/cloudfront
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## 모듈 구성

### EKS 모듈
- **EKS 클러스터**: v1.31 with managed node groups
- **Add-ons**: VPC CNI, CoreDNS, EBS CSI Driver, EFS CSI Driver, Metrics Server
- **Helm 차트**: Cluster Autoscaler, Istio Service Mesh
- **보안**: Pod Identity, IRSA 지원

### Istio 설정
- **버전**: 1.24.2
- **구성**: istiod + ingress gateway
- **노드 셀렉터**: mgmt 노드 그룹 타겟팅
- **서비스 타입**: NodePort

### 기타 모듈
- **VPC**: 완전한 네트워킹 스택 (Public/Private 서브넷, NAT Gateway, IGW)
- **EC2**: 보안 그룹 포함 인스턴스 배포
- **ALB**: 타겟 그룹 및 리스너 설정
- **CloudFront**: S3/ALB 오리진 지원

## 환경 설정

각 환경의 `test.tfvars` 또는 `terraform.tfvars` 파일에서 환경별 변수를 설정할 수 있습니다.

## 주의사항

- EKS 배포 시 Helm 차트 설치에 시간이 소요될 수 있습니다 (timeout: 10000초)
- Istio 설치는 istio-base → istiod → ingress gateway 순서로 진행됩니다
- 모든 리소스는 `mgmt` 노드 그룹에 배포되도록 설정되어 있습니다