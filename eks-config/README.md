# EKS 1.31 Helmfile 기반 자동 배포 구성

이 디렉토리는 EKS 1.31 환경에 Helmfile 기반으로 다음 컴포넌트들을 자동 배포하기 위한 구성을 포함합니다:

- ArgoCD (v5.51.6)
- Fluentd (v0.5.0)
- Istio (v1.22.1, Ingress 포함)
- Metrics Server (v3.11.0)
- AWS Load Balancer Controller (v1.6.2)

## 디렉토리 구조

```
eks-config/
├── helmfile.yaml            # 루트 Helmfile
├── helmfile/                # 컴포넌트별 Helmfile
│   ├── argocd.yaml
│   ├── fluentd.yaml
│   ├── istio.yaml
│   ├── metrics-server.yaml
│   ├── aws-lb-controller.yaml
│   └── ingress.yaml
└── values/                  # 컴포넌트별 values 파일
    ├── argocd-values.yaml
    ├── fluentd-values.yaml
    ├── istio-values.yaml
    ├── metrics-values.yaml
    ├── lb-controller-values.yaml
    └── ingress-values.yaml
```

## 주요 변경사항

- 모든 컴포넌트에 `node-group: mgmt` 노드 셀렉터 적용
- Istio 버전을 1.20.3에서 1.22.1로 업데이트
- 리소스 요청 및 제한 최적화
- AWS Load Balancer Controller 설정 개선

## Helm Repository 등록

다음 명령어로 필요한 Helm repository를 등록합니다:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add fluent https://fluent.github.io/helm-charts
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

## Helmfile 배포 명령

전체 구성 배포는 다음 명령어로 실행합니다:

```bash
cd eks-config
helmfile apply
```

## 배포 후 검증

배포 후 네임스페이스 별 리소스 상태를 확인합니다:

```bash
kubectl get all -n argocd
kubectl get all -n istio-system
kubectl get all -n logging
kubectl get all -n istio-ingress
kubectl get all -n kube-system | grep -E 'metrics-server|aws-load-balancer-controller'
```