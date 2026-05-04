resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = false
  version    = "7.7.7"
  wait = true
  timeout = 900

  depends_on = [kubernetes_secret.my-db-postgresql_backend]
}
resource "time_sleep" "wait_for_argocd" {
  depends_on = [helm_release.argocd]
  create_duration = "30s"
}
data "kubernetes_secret" "argocd_admin_pwd" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [time_sleep.wait_for_argocd]
}

resource "null_resource" "cleanup_apiservice" {
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete apiservice v1beta1.custom.metrics.k8s.io --ignore-not-found=true || true"
  }

  depends_on = [
    helm_release.argocd
  ]
}
