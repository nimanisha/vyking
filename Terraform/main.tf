terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "kubernetes" {
  config_path    = "C:/Users/Nima/kubeconfig.yaml"  
  config_context = "k3d-${var.cluster_name}"
}

# Configure Helm provider for K3D cluster
provider "helm" {
  kubernetes {
    config_path    = "C:/Users/Nima/kubeconfig.yaml"
    config_context = "k3d-${var.cluster_name}"
  }
}

# Just reference existing namespaces - don't create them
data "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
  }
}

data "kubernetes_namespace" "default" {
  metadata {
    name = var.application_namespace
  }
}

# Fetch ArgoCD CRDs
data "http" "argocd_crds" {
  url = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds.yaml"
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"
  namespace  = var.argocd_namespace
  
  create_namespace = false
  timeout         = 600
  
  values = [
    yamlencode({
      global = {
        domain = "localhost:30080"
      }
      
      controller = {
        env = [
          {
            name  = "ARGOCD_CONTROLLER_REPLICAS"
            value = "1"
          },
          {
            name  = "ARGOCD_APPLICATION_CONTROLLER_REPO_SERVER_TIMEOUT_SECONDS"
            value = "300"
          }
        ]
        metrics = {
          enabled = true
          service = {
            type = "ClusterIP"
          }
        }
      }
      
      server = {
        extraArgs = ["--insecure"]
        config = {
          "admin.enabled" = "true"
          "application.instanceLabelKey" = "argocd.argoproj.io/instance"
          "application.resourceTrackingMethod" = "annotation"
          "exec.enabled" = "true"
          "server.rbac.log.enforce.enable" = "false"
          "timeout.reconciliation" = "180s"
          "timeout.hard.reconciliation" = "0s"
        }
        rbacConfig = {
          "policy.default" = "role:readonly"
          "policy.csv" = join("\n", [
            "p, role:admin, applications, *, */*, allow",
            "p, role:admin, clusters, *, *, allow", 
            "p, role:admin, repositories, *, *, allow",
            "p, role:admin, logs, get, *, allow",
            "p, role:admin, exec, create, */*, allow",
            "g, argocd-admins, role:admin"
          ])
        }
        service = {
          type = "ClusterIP"
          port = 80
          portName = "server"
        }
        metrics = {
          enabled = true
          service = {
            type = "ClusterIP"
          }
        }
      }
      
      repoServer = {
        env = [
          {
            name  = "ARGOCD_EXEC_TIMEOUT"
            value = "5m"
          },
          {
            name  = "ARGOCD_REPO_SERVER_TIMEOUT_SECONDS"
            value = "300"
          }
        ]
        metrics = {
          enabled = true
          service = {
            type = "ClusterIP"
          }
        }
      }
      
      applicationSet = {
        enabled = true
      }
      
      dex = {
        enabled = false
      }
      
      notifications = {
        enabled = false
      }
    })
  ]
}

# Create NodePort service for ArgoCD server
resource "kubernetes_service" "argocd_server_nodeport" {
  metadata {
    name      = "argocd-server-nodeport"
    namespace = var.argocd_namespace
    labels = {
      "app.kubernetes.io/name"      = "argocd-server"
      "app.kubernetes.io/part-of"   = "argocd"
      "app.kubernetes.io/component" = "server"
    }
  }
  
  spec {
    type = "NodePort"
    
    selector = {
      "app.kubernetes.io/name"      = "argocd-server"
      "app.kubernetes.io/instance"  = "argocd"
      "app.kubernetes.io/component" = "server"
    }
    
    port {
      name        = "server"
      port        = 80
      target_port = 8080
      node_port   = 30080
    }
  }
  
  depends_on = [helm_release.argocd]
}

# Wait for ArgoCD to be ready
resource "time_sleep" "wait_for_argocd" {
  depends_on = [helm_release.argocd]
  create_duration = "90s"
}

# Get ArgoCD admin password
data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.argocd_namespace
  }
  depends_on = [time_sleep.wait_for_argocd]
}

# MySQL Application
resource "kubernetes_manifest" "mysql_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "mysql"
      namespace = var.argocd_namespace
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
        "app.kubernetes.io/part-of"    = "infrastructure"
      }
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://charts.bitnami.com/bitnami"
        chart          = "mysql"
        targetRevision = "9.14.4"
        helm = {
          releaseName = "mysql"
          values = <<-EOT
            # Bitnami MySQL Helm Chart Values
            auth:
              rootPassword: "root-secret-password-123"
              database: "webapp_db"
              username: "webapp_user"
              password: "webapp-user-password-123"

            primary:
              persistence:
                enabled: true
                size: 8Gi
                storageClass: "local-path"
                accessModes:
                  - ReadWriteOnce

              service:
                type: ClusterIP
                ports:
                  mysql: 3306

              configuration: |-
                [mysqld]
                default_authentication_plugin=mysql_native_password
                skip-name-resolve
                explicit_defaults_for_timestamp
                basedir=/opt/bitnami/mysql
                plugin_dir=/opt/bitnami/mysql/lib/plugin
                port=3306
                socket=/opt/bitnami/mysql/tmp/mysql.sock
                datadir=/bitnami/mysql/data
                tmpdir=/opt/bitnami/mysql/tmp
                max_allowed_packet=16M
                bind-address=0.0.0.0
                pid-file=/opt/bitnami/mysql/tmp/mysqld.pid
                log-error=/opt/bitnami/mysql/logs/mysqld.log
                character-set-server=UTF8
                collation-server=utf8_general_ci
                slow_query_log=0
                slow_query_log_file=/opt/bitnami/mysql/logs/mysqld.log
                long_query_time=10.0

            architecture: standalone

            metrics:
              enabled: false

            volumePermissions:
              enabled: true
          EOT
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.application_namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
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
      ignoreDifferences = [
        {
          group = "apps"
          kind  = "Deployment"
          jsonPointers = ["/spec/replicas"]
        }
      ]
    }
  }
  depends_on = [time_sleep.wait_for_argocd]
}

# Web Application
resource "kubernetes_manifest" "applications_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "webapp"
      namespace = var.argocd_namespace
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
        "app.kubernetes.io/part-of"    = "applications"
      }
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.git_repository
        path           = "applications/webapp-helm-chart"
        targetRevision = var.git_branch
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
          prune    = true
          selfHeal = true
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
  depends_on = [time_sleep.wait_for_argocd]
}

# Infrastructure Application
resource "kubernetes_manifest" "infrastructure_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "infrastructure"
      namespace = var.argocd_namespace
      labels = {
        "app.kubernetes.io/managed-by" = "terraform"
        "app.kubernetes.io/part-of"    = "infrastructure"
      }
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.git_repository
        path           = "infrastructure"
        targetRevision = var.git_branch
        directory = {
          recurse = true
          include = "backup-cronjob.yaml"
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.application_namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
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
  depends_on = [time_sleep.wait_for_argocd]
}