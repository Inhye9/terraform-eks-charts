# ★ aws-load-balancer-controller 미사용으로 주석 처리(aws_lb_controller_pod_identity도 주석)
# resource "helm_release" "aws-load-balancer-controller" {
#   repository = "https://aws.github.io/eks-charts"  
#   chart      = "aws-load-balancer-controller"  // Helm 차트 패키지 이름  
#   name       = "aws-load-balancer-controller"  // EKS 배포 시 설정할 차트 이름
#   namespace  = "kube-system"
#   version    = var.eks_addon_versions["aws-lb-controller"]
#   timeout    = 10000 // 15분 토큰 만료 해결 test

#   dynamic "set" {
#     for_each = {
#       "clusterName"             = module.eks.cluster_name
#       "serviceAccount.create"   = "true"
#       "serviceAccount.name"     = "aws-load-balancer-controller-sa"
#       "nodeSelector.node-group" = "mgmt"
#       // 아래 옵션은 사용하지 않지만 기본값이 true임, 불필요한 로깅 방지를 위해 비활성화
#       "enableShield"            = "false"
#       "enableWaf"               = "false"
#       "enableWafv2"             = "false"
#     }
#     content {
#       name =  set.key
#       value = set.value
#     }
#   }
#   depends_on = [module.aws_lb_controller_pod_identity]  
# }


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

# istio-system namespace 사전 생성 
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

# ★ 기존 istio helm 차트 방식 주석 처리
# resource "helm_release" "istio_base" {
#   name       = "istio-base"
#   namespace  = kubernetes_namespace.istio_system.metadata.0.name
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "base"
#   version    = "1.24.2"
#   timeout    = 10000

#   depends_on = [kubernetes_namespace.istio_system]
# }

# resource "helm_release" "istiod" {
#   name       = "istiod"
#   namespace  = kubernetes_namespace.istio_system.metadata.0.name
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "istiod"
#   version    = "1.24.2"
#   timeout    = 10000
#   depends_on = [helm_release.istio_base]

#   set {
#     name  = "pilot.nodeSelector.node-group"
#     value = "mgmt"
#   }
# }

# resource "helm_release" "istio_ingress" {
#   name       = "istio-ingress"
#   namespace  = kubernetes_namespace.istio_system.metadata.0.name
#   repository = "https://istio-release.storage.googleapis.com/charts"
#   chart      = "gateway"
#   version    = "1.24.2"
#   timeout    = 10000
#   depends_on = [helm_release.istiod]

#   set {
#     name  = "service.type"
#     value = "NodePort"
#   }

#   set {
#     name  = "nodeSelector.node-group"
#     value = "mgmt"
#   }
# }

# istioctl install과 동일한 설정으로 istiod 설치
resource "helm_release" "istio" {
  name       = "istiod"
  namespace  = kubernetes_namespace.istio_system.metadata.0.name
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.24.2"
  timeout    = 10000
  cleanup_on_fail = true

  dynamic "set" {
    for_each = {
      "global.proxy.image"                                = "proxyv2"
      "global.hub"                                        = "docker.inner-thehandsome.com/istio"
      "gateways.istio-ingressgateway.enabled"             = "true"
      "gateways.istio-ingressgateway.type"                = "NodePort"
      "gateways.istio-ingressgateway.nodeSelector.node-group" = "mgmt"
      "pilot.nodeSelector.node-group"                     = "mgmt"
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [kubernetes_namespace.istio_system]
}