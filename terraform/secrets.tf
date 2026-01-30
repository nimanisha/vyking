resource "kubernetes_secret" "ghcr-login_backend" {
    metadata {
      name = "ghcr-login"
      namespace = "backend"
    }
  
}