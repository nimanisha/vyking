resource "kubernetes_secret" "ghcr-login_backend" {
  metadata {
    name      = "ghcr-login"
    namespace = "backend"
  }

  # استفاده از نوع رسمی داکر
  type = "kubernetes.io/dockerconfigjson"

  # استفاده از binary_data باعث می‌شود ترافورم دیگر محتوا را دستکاری نکند
  binary_data = {
    ".dockerconfigjson" = base64encode(jsonencode({
      auths = {
        "ghcr.io" = {
          username = "nimanisha"
          password = var.dockerconfigjson
          # فقط بخش داخلی یوزر:پسورد نیاز به انکود دارد
          auth     = base64encode("nimanisha:${var.dockerconfigjson}")
        }
      }
    }))
  }
  depends_on = [kubernetes_namespace.ns]
}

resource "kubernetes_secret" "my-db-postgresql_backend" {
    for_each = setsubtract(toset(local.namespace), ["argocd"])
    metadata {
      name = "my-db-postgresql"
      namespace = each.value
    }
    type = "Opaque"
    data = {
        postgres-password = var.postgres_password
    }
    depends_on = [kubernetes_namespace.ns]
}   
resource "kubernetes_secret" "ghcr_repo_all" {
  metadata {
    name      = "ghcr-repo-all"
    namespace = "argocd"
    labels    = { "argocd.argoproj.io/secret-type" = "repository" }
  }
  data = {
    name      = "ghcr-nimanisha"
    type      = "helm"
    url       = "ghcr.io/nimanisha" 
    enableOCI = "true"
    username  = "nimanisha"
    password  = var.dockerconfigjson
  }
}
