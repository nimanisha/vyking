resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  version    = "1.20.0"
  depends_on = [kubernetes_secret.istio_tls]


}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  version    = "1.20.0"
  depends_on = [helm_release.istio_base]

  values = [
    <<-EOF
    meshConfig:
      defaultProviders:
        metrics:
          - prometheus
    EOF
  ]
}

resource "helm_release" "istio_ingressgateway" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = "istio-system"
  version    = "1.20.0"
  wait = false
  timeout = 600
  depends_on = [helm_release.istiod]

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}