# resource "null_resource" "istio_telemetry" {
#   provisioner "local-exec" {
#     command = <<EOT
#       echo "Waiting for Istio Telemetry API to be ready..."
      
#       for i in {1..10}; do
#         kubectl apply -f - <<EOF && echo "Telemetry applied successfully!" && break
# apiVersion: telemetry.istio.io/v1alpha1
# kind: Telemetry
# metadata:
#   name: mesh-default
#   namespace: istio-system
# spec:
#   metrics:
#     - providers:
#         - name: otel-metrics
#   accessLogging:
#     - providers:
#         - name: otel-metrics
# EOF
#         echo "API not ready yet (Attempt $i/10). Retrying in 5 seconds..."
#         sleep 5
#       done
#     EOT
#   }

#   depends_on = [helm_release.istio_ingressgateway]
# }

# resource "helm_release" "otel_collector" {
#   name       = "otel-collector"
#   repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
#   chart      = "opentelemetry-collector"
#   namespace  = "istio-system"
#   version    = "0.110.0"

#   values = [
#     <<-EOF
#     mode: deployment
#     replicaCount: 1

#     clusterRole:
#       create: true
#       rules:
#         - apiGroups: [""]
#           resources: ["pods", "namespaces", "endpoints", "services", "nodes"]
#           verbs: ["get", "watch", "list"]
    
#     image:
#       repository: "otel/opentelemetry-collector-contrib"
#       tag: "0.110.0"

#     config:
#       extensions:
#         health_check:
#           endpoint: 0.0.0.0:13133

#       receivers:
#         prometheus:
#           config:
#             scrape_configs:
#               - job_name: 'istio-mesh'
#                 kubernetes_sd_configs:
#                   - role: pod
#                 relabel_configs:
#                   - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
#                     action: keep
#                     regex: "true"
#                   # خواندن مسیر متریک (معمولا /stats/prometheus)
#                   - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
#                     action: replace
#                     target_label: __metrics_path__
#                     regex: (.+)
#                   # ترکیب IP پاد و پورت 15020 برای Scrape
#                   - source_labels: [__meta_kubernetes_pod_ip, __meta_kubernetes_pod_annotation_prometheus_io_port]
#                     action: replace
#                     regex: ([^:]+)(?::\d+)?;(\d+)
#                     replacement: $1:$2
#                     target_label: __address__
#                   # اضافه کردن لیبل های namespace و pod برای HPA
#                   - source_labels: [__meta_kubernetes_namespace]
#                     action: replace
#                     target_label: namespace
#                   - source_labels: [__meta_kubernetes_pod_name]
#                     action: replace
#                     target_label: pod

#       processors:
#         batch: {}

#       exporters:
#         debug:
#           verbosity: detailed
#         prometheusremotewrite:
#           endpoint: "http://victoria-metrics-victoria-metrics-single-server.istio-system.svc.cluster.local:8428/api/v1/write"

#       service:
#         extensions: [health_check]
#         pipelines:
#           metrics:
#             receivers: [prometheus] 
#             processors: [batch]
#             exporters: [prometheusremotewrite, debug]
#     EOF
#   ]
# }