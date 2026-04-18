resource "helm_release" "victoria_metrics" {
  name       = "victoria-metrics"
  repository = "https://victoriametrics.github.io/helm-charts/"
  chart      = "victoria-metrics-single"
  namespace  = "istio-system"
  # version    = "0.10.2" 

  set {
    name  = "server.retentionPeriod"
    value = "1" 
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = "false" 
  }

  depends_on = [helm_release.otel_collector]
}

resource "helm_release" "kiali_server" {
  name       = "kiali-server"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  namespace  = "istio-system"
  version    = "1.79.0"

  set {
    name  = "auth.strategy"
    value = "anonymous"
  }

  set {
    name  = "external_services.prometheus.url"
    value = "http://victoria-metrics-victoria-metrics-single.istio-system.svc.cluster.local:8428"
  }

  set {
    name  = "deployment.instance_name"
    value = "kiali"
  }

  depends_on = [helm_release.victoria_metrics]
}