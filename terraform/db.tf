resource "helm_release" "postgresql" {
  name       = "my-db"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "18.2.0"
  namespace  = kubernetes_namespace.db.metadata[0].name

  set {
    name  = "global.postgresql.auth.postgresPassword"
    value = "mypassword123"
  }

  set {
    name  = "image.tag"
    value = "18.1.0"
  }

  depends_on = [kubernetes_namespace.db]
}