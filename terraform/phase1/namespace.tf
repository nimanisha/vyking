locals {
  all_namespaces = ["db", "backend", "argocd", "istio-system"]
  istio_enabled_namespaces = ["backend", "frontend", ]
}
resource "kubernetes_namespace" "ns" {
  for_each = toset(local.all_namespaces)
  
  metadata {
    name = each.value
    labels = merge(
      { "app.kubernetes.io/managed-by" = "terraform" },
      
      contains(local.istio_enabled_namespaces, each.value) ? {
        "istio-injection" = "enabled"
      } : {}
    )
  }
}
