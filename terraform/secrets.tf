# resource "kubernetes_secret" "ghcr-login_backend" {
#     metadata {
#       name = "ghcr-login"
#       namespace = "backend"
#     }
#     type = "kubernetes.io/dockerconfigjson"
    
#     data = {
#       ".dockerconfigjson" = base64encode(jsonencode({
#         auths = {
#             "ghcr.io": {
#                 username = "nimanisha"
#                 password = var.dockerconfigjson
#             }
#         }
#       }))
#     }
#     depends_on = [kubernetes_namespace.ns]
# }
resource "kubernetes_secret" "ghcr-login_backend" {
    metadata {
      name = "ghcr-login"
      namespace = "backend"
    }
    type = "kubernetes.io/dockerconfigjson"
    
    data = {
      ".dockerconfigjson" = jsonencode({
        auths = {
            "ghcr.io" = {
                username = "nimanisha"
                password = var.dockerconfigjson
                auth     = base64encode("nimanisha:${var.dockerconfigjson}")
            }
        }
      })
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