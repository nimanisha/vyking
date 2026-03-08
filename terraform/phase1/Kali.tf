resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = "istio-system" 
  version    = "25.21.0"

  set {
    name  = "alertmanager.enabled"
    value = "false"
  }
  set {
    name  = "server.persistentVolume.enabled"
    value = "false" 
  }
  set {
    name  = "pushgateway.enabled"
    value = "false"
  }

  depends_on = [helm_release.istiod]
}

resource "helm_release" "kiali_server" {
  name       = "kiali-server"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = "istio-system"

  set {
    name  = "auth.strategy"
    value = "anonymous" 
  }

  set {
    name  = "external_services.prometheus.url"
    value = "http://prometheus-server.istio-system.svc.cluster.local"
  }

  depends_on = [helm_release.prometheus]
}