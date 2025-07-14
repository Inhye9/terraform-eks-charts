# ★ aws-load-balancer-controller 미사용으로 주석 처리(aws_lb_controller_pod_identity도 주석)
resource "helm_release" "aws-load-balancer-controller" {
  repository = "https://aws.github.io/eks-charts"  
  chart      = "aws-load-balancer-controller"  // Helm 차트 패키지 이름  
  name       = "aws-load-balancer-controller"  // EKS 배포 시 설정할 차트 이름
  namespace  = "kube-system"
  version    = var.eks_addon_versions["aws-lb-controller"]
  timeout    = 10000 // 15분 토큰 만료 해결 test

  dynamic "set" {
    for_each = {
      "clusterName"             = module.eks.cluster_name
      "serviceAccount.create"   = "true"
      "serviceAccount.name"     = "aws-load-balancer-controller-sa"
      "nodeSelector.node-group" = "mgmt"
      // 아래 옵션은 사용하지 않지만 기본값이 true임, 불필요한 로깅 방지를 위해 비활성화
      "enableShield"            = "false"
      "enableWaf"               = "false"
      "enableWafv2"             = "false"
    }
    content {
      name =  set.key
      value = set.value
    }
  }
  depends_on = [module.aws_lb_controller_pod_identity]  
}


resource "helm_release" "cluster-autoscaler" {
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"  // Helm 차트 패키지 이름
  name       = "cluster-autoscaler"  // EKS 배포 시 설정할 차트 이름
  namespace  = "kube-system"
  version    = var.eks_addon_versions["cluster-autoscaler"]
  timeout    = 10000 // 15분 토큰 만료 해결 test

  dynamic "set" {
    for_each = {
      "fullnameOverride"                                  = "cluster-autoscaler"
      "autoDiscovery.clusterName"                         = module.eks.cluster_name
      "awsRegion"                                         = "ap-northeast-2"
      "rbac.serviceAccount.create"                        = "true"
      "rbac.serviceAccount.name"                          = "cluster-autoscaler-sa"
      "securityContext.runAsNonRoot"                      = "true"
      "securityContext.runAsUser"                         = "65534"
      "securityContext.fsGroup"                           = "65534"
      "securityContext.seccompProfile.type"               = "RuntimeDefault"
      "containers.resources.limits.cpu"                   = "100m"
      "containers.resources.limits.memory"                = "600Mi"
      "containers.resources.requests.cpu"                 = "100m"
      "containers.resources.requests.memory"              = "600Mi"
      "extraArgs.skip-nodes-with-local-storage"           = "false"
      "extraArgs.expander"                                = "least-waste"
      "extraArgs.balance-similar-node-groups"             = "true"
      "extraArgs.skip-nodes-with-system-pods"             = "false"
      "extraArgs.scale-down-delay-after-add"              = "3m"
      "extraArgs.scale-down-unneeded-time"                = "3m"
      "containerSecurityContext.allowPrivilegeEscalation" = "false"
      "containerSecurityContext.capabilities.drop[0]"     = "ALL"
      "containerSecurityContext.readOnlyRootFilesystem"   = "true"
    }
    content {
      name =  set.key
      value = set.value
    }
  }
  depends_on = [module.cluster_autoscaler_pod_identity]
}

# ----------------------------------------------------------------------------------
# helm-release istio 
# istio-helm chart: https://github.com/istio/istio/tree/master/manifests/charts 
# terraform helm provider: https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release 
# 
# repo check 
# helm repo add istio https://istio-release.storage.googleapis.com/charts
# helm search repo istio
# ----------------------------------------------------------------------------------
# istio-system namespace 사전 생성 
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

# 1. istio-base (CRDs 포함)
resource "helm_release" "istio_base" {
  name       = "istio-base"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.24.2"
  timeout    = 10000

  cleanup_on_fail = true

  depends_on = [kubernetes_namespace.istio_system]
}

# 2. istiod (control plane)
resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.24.2"
  timeout    = 10000

  cleanup_on_fail = true

  depends_on = [helm_release.istio_base]

  values = [
    file("${path.module}/helm_values/istio/istiod-values.yaml")
  ]
}

# 3. (선택) istio-ingressgateway
resource "helm_release" "istio_ingress" {
  name       = "istio-ingressgateway"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.24.2"
  timeout    = 10000

  cleanup_on_fail = true

  depends_on = [helm_release.istiod]

  values = [
    file("${path.module}/helm_values/istio/istio-ingressgateway-values.yaml")
  ]
}

# ----------------------------------------------------------------------------------
# helm release argocd 
# argcod app version 2.14.2 -> chart version 6.7.4. app version 별도 명시 필요 없음
# argocd helm chart github: https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd
# ----------------------------------------------------------------------------------
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.4" # <- ArgoCD 앱 버전 2.14.2 포함

  create_namespace = false
  wait             = true
  timeout          = 300

  values = [
    file("${path.module}/helm_values/argocd/argocd-values.yaml")
  ]
}


# ----------------------------------------------------------------------------------
# helm release fluentd
# fluentd 1.0.0 install -> helm chart 이용
# ----------------------------------------------------------------------------------
resource "kubernetes_namespace" "fluentd" {
  metadata {
    name = "fluentd"
  }
}

resource "helm_release" "fluentd" {
  name       = "fluentd"
  namespace  = kubernetes_namespace.fluentd.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "${path.module}/helm_values/fluentd"
  version    = "1.0.0" # chart version

  create_namespace = false
  wait             = true
  timeout          = 300

  values = [
    file("${path.module}/helm_values/fluentd/fluentd-values.yaml")
  ]
}
