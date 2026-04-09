resource "kubernetes_secret" "ghcr-login_backend" {
  metadata {
    name      = "ghcr-login"
    namespace = "backend"
  }

  type = "kubernetes.io/dockerconfigjson"

  binary_data = {
    ".dockerconfigjson" = base64encode(jsonencode({
      auths = {
        "ghcr.io" = {
          username = "nimanisha"
          password = var.dockerconfigjson
          auth     = base64encode("nimanisha:${var.dockerconfigjson}")
        }
      }
    }))
  }
  depends_on = [kubernetes_namespace.ns]
}

resource "kubernetes_secret" "my-db-postgresql_backend" {
    for_each = toset(["db", "backend"])
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
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem
  dns_names = ["frontend.k3d.localhost", "localhost"]
  subject {
    common_name  = "frontend.k3d.localhost"
    organization = "MyOrg"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret" "istio_tls" {
  for_each = toset(["istio-system", "default"])
  metadata {
    name      = "main-gateway-cert"
    namespace = each.value
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.example.cert_pem
    "tls.key" = tls_private_key.example.private_key_pem
  }
}