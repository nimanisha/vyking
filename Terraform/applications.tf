# MySQL Application (using Bitnami Helm Chart)
resource "kubernetes_manifest" "mysql_app" {
  depends_on = [time_sleep.wait_for_argocd]
  
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "mysql"
      namespace = var.argocd_namespace
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
        "app.kubernetes.io/part-of"    = "infrastructure"
      }
    }
    spec = {
      project = "default"
      
      source = {
        repoURL        = "https://charts.bitnami.com/bitnami"
        targetRevision = "9.14.4"
        chart          = "mysql"
        helm = {
          releaseName = "mysql"
          values = file("${path.module}/../infrustructure/mysql/values.yaml") 
        }
      }
      
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.application_namespace
      }
      
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = false
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true",
          "ApplyOutOfSyncOnly=true"
        ]
        retry = {
          limit = 5
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
      }
      
      # Health check configuration
      ignoreDifferences = [
        {
          group = "apps"
          kind  = "Deployment"
          jsonPointers = [
            "/spec/replicas"
          ]
        }
      ]
    }
  }
}

# Infrastructure Application (monitors infrastructure/ directory)
resource "kubernetes_manifest" "infrastructure_app" {
  depends_on = [kubernetes_manifest.mysql_app]
  
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "infrastructure"
      namespace = var.argocd_namespace
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
        "app.kubernetes.io/part-of"    = "infrastructure"
      }
    }
    spec = {
      project = "default"
      
      source = {
        repoURL        = var.git_repo_url
        targetRevision = var.git_branch
        path           = "infrastructure"
        directory = {
          recurse = true
          include = "backup-cronjob.yaml"  # Only include backup CronJob
        }
      }
      
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.application_namespace
      }
      
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = false
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true",
          "ApplyOutOfSyncOnly=true"
        ]
        retry = {
          limit = 5
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
      }
    }
  }
}

# Applications Application (monitors applications/ directory)
resource "kubernetes_manifest" "applications_app" {
  depends_on = [kubernetes_manifest.mysql_app]
  
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "webapp"
      namespace = var.argocd_namespace
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
        "app.kubernetes.io/part-of"    = "applications"
      }
    }
    spec = {
      project = "default"
      
      source = {
        repoURL        = var.git_repo_url
        targetRevision = var.git_branch
        path           = "applications/webapp-helm-chart"
        helm = {
          releaseName = "webapp"
        }
      }
      
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.application_namespace
      }
      
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = false
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true",
          "ApplyOutOfSyncOnly=true"
        ]
        retry = {
          limit = 5
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "3m"
          }
        }
      }
    }
  }
}

# Output application information
output "argocd_applications" {
  description = "ArgoCD applications created"
  value = {
    mysql = {
      name      = "mysql"
      namespace = var.argocd_namespace
      type      = "Bitnami Helm Chart"
    }
    infrastructure = {
      name      = "infrastructure"
      namespace = var.argocd_namespace
      type      = "Git Directory"
      path      = "infrastructure/"
    }
    webapp = {
      name      = "webapp"
      namespace = var.argocd_namespace
      type      = "Custom Helm Chart"
      path      = "applications/webapp-helm-chart/"
    }
  }
}
