locals {
  all_namespaces = ["db", "backend", "argocd", "istio-system", "frontend"]
  istio_enabled_namespaces = ["backend", "frontend", ]
}
resource "kubernetes_namespace" "ns" {
  for_each = toset(local.all_namespaces)
  
  metadata {
    name = each.value
    labels = contains(local.istio_enabled_namespaces, each.value) ? {
      istio-injection = "enabled"
    } : {}
  }
  # depends_on = [null_resource.k3d_cluster]
}

