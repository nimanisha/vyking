resource "helm_release" "kiali_server" {
  name       = "kiali-server"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = "istio-system"

  set {
    name  = "auth.strategy"
    value = "anonymous" 
  }

  depends_on = [helm_release.istiod]
}