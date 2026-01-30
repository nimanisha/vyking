resource "kubernetes_secret" "ghcr-login_backend" {
    metadata {
      name = "ghcr-login"
      namespace = "backend"
    }
    type = "kubernetes.io/dockerconfigjson"
    
    data = {
      ".dockerconfigjson" = base64encode(jsonencode({
        auths = {
            "ghcr.io": {
                username = nimanisha
                password = var.dockerconfigjson
            }
        }
      }))
    }
}

resource "kubernetes_secret" "my-db-postgresql_backend" {
    metadata {
      name = "my-db-postgresql"
      namespace = var.namespace
    }
    type = "Opaque"
    data = {
        postgres-password = var.postgres_password
    }
}   