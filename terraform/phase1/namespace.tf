locals {
  namespace = [ "db", "backend", "argocd"]
}
resource "kubernetes_namespace" "ns" {
  for_each = toset(local.namespace)
  
  metadata {
    name = each.value
  }
  depends_on = [null_resource.k3d_cluster]
}

