resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = false

  wait = true

  depends_on = [kubernetes_secret.my-db-postgresql_backend]
}
resource "time_sleep" "wait_for_argocd" {
  depends_on = [helm_release.argocd]
  create_duration = "30s"
}

