resource "helm_release" "prometheus_adapter" {
  name       = "prometheus-adapter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-adapter"
  namespace  = "istio-system"
  version    = "4.11.0"

  set {
    name  = "prometheus.url"
    value = "http://victoria-metrics-victoria-metrics-single.istio-system.svc.cluster.local"
  }
  
  set {
    name  = "prometheus.port"
    value = "8428"
  }

  values = [
    <<-EOF
    rules:
      default: false
      custom:
      - seriesQuery: 'istio_request_duration_milliseconds_bucket'
        resources:
          overrides:
            namespace: {resource: "namespace"}
            destination_service_name: {resource: "service"}
        name:
          matches: "istio_request_duration_milliseconds_bucket"
          as: "istio_requests_latency_p95"
        metricsQuery: "histogram_quantile(0.95, sum(rate(<<.Series>>{<<.LabelMatchers>>}[2m])) by (le, <<.GroupBy>>))"
    EOF
  ]

  depends_on = [helm_release.victoria_metrics]
}