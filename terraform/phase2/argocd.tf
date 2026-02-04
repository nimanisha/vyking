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
      ignoreDifferences = [
        {
          group = ""
          kind  = "PersistentVolumeClaim"
          name  = "postgres-backup-pvc"
        }
      ]
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