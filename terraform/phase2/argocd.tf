
# data "kubernetes_secret" "argocd_admin_secret" {
#   metadata {
#     name      = "argocd-initial-admin-secret"
#     namespace = "argocd"
#   }
  # depends_on = [time_sleep.wait_for_argocd]
# }
# resource "null_resource" "register_ghcr_repo" {
  # depends_on = [data.kubernetes_secret.argocd_admin_secret]

#   provisioner "local-exec" {
#     command = <<EOT
#       kubectl port-forward svc/argocd-server -n argocd 8080:443 & 
#       PF_PID=$!
      
#       sleep 10
      
#       ARGOCD_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)
      
#       argocd repo add ghcr.io/nimanisha/charts \
#         --type helm \
#         --name ghcr-charts \
#         --enable-oci \
#         --username nimanisha \
#         --password ${var.dockerconfigjson} \
#         --server localhost:8080 \
#         --auth-token $ARGOCD_PASSWORD \
#         --insecure

#       kill $PF_PID
#     EOT
#   }
# }


resource "kubernetes_manifest" "infrastructure_db" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "infrastructure-db"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/nimanisha/vyking.git"
        targetRevision = "main"
        path            = "infrastructure"
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "db"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=false"]
      }
    }
  }
  # depends_on = [null_resource.register_ghcr_repo, kubernetes_secret.ghcr_repo_config]
}

# 2. Backend Application
resource "kubernetes_manifest" "backend_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "backend-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "ghcr.io/nimanisha"
        chart          = "charts/backend-chart"
        targetRevision = "1.0.*"
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "backend"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=false"]
      }
    }
  }
  depends_on = [kubernetes_manifest.infrastructure_db]
}

# 3. Frontend Application
resource "kubernetes_manifest" "frontend_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "frontend-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "ghcr.io/nimanisha"
        chart          = "charts/frontend-chart"
        targetRevision = "1.0.*"
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=false"]
      }
    }
  }
  depends_on = [kubernetes_manifest.backend_app]
}