# Install ArgoCD using official Helm chart
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.argocd_version
  
  timeout = 600
  wait    = true

  values = [
    yamlencode({
      # Global configuration
      global = {
        domain = "localhost:30080"
      }
      
      # Server configuration
      server = {
        extraArgs = [
          "--insecure",  # Disable TLS for local development
        ]
        
        config = {
          "application.instanceLabelKey" = "argocd.argoproj.io/instance"
          "server.rbac.log.enforce.enable" = "false"
          "exec.enabled" = "true"
          "admin.enabled" = "true"
          "timeout.reconciliation" = "180s"
          "timeout.hard.reconciliation" = "0s"
          "application.resourceTrackingMethod" = "annotation"
        }
        
        # RBAC configuration
        rbacConfig = {
          "policy.default" = "role:readonly"
          "policy.csv" = <<-EOT
            p, role:admin, applications, *, */*, allow
            p, role:admin, clusters, *, *, allow
            p, role:admin, repositories, *, *, allow
            p, role:admin, logs, get, *, allow
            p, role:admin, exec, create, */*, allow
            g, argocd-admins, role:admin
          EOT
        }
        
        # Service configuration
        service = {
          type = "ClusterIP"
          port = 80
          portName = "server"
        }
        
        # Metrics
        metrics = {
          enabled = true
          service = {
            type = "ClusterIP"
          }
        }
      }
      
      # Repository server configuration
      repoServer = {
        env = [
          {
            name = "ARGOCD_EXEC_TIMEOUT"
            value = "5m"
          },
          {
            name = "ARGOCD_REPO_SERVER_TIMEOUT_SECONDS"
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
      
      # Application controller configuration  
      controller = {
        env = [
          {
            name = "ARGOCD_CONTROLLER_REPLICAS"
            value = "1"
          },
          {
            name = "ARGOCD_APPLICATION_CONTROLLER_REPO_SERVER_TIMEOUT_SECONDS"
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
      
      # Disable Dex for simplicity
      dex = {
        enabled = false
      }
      
      # Disable notifications
      notifications = {
        enabled = false
      }
      
      # Application Set Controller
      applicationSet = {
        enabled = true
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Create NodePort service for external access
resource "kubernetes_service" "argocd_server_nodeport" {
  depends_on = [helm_release.argocd]
  
  metadata {
    name      = "argocd-server-nodeport"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "app.kubernetes.io/component" = "server"
      "app.kubernetes.io/name"      = "argocd-server"
      "app.kubernetes.io/part-of"   = "argocd"
    }
  }

  spec {
    type = "NodePort"
    
    port {
      name        = "server"
      port        = 80
      target_port = 8080
      node_port   = 30080
      protocol    = "TCP"
    }

    selector = {
      "app.kubernetes.io/component" = "server"
      "app.kubernetes.io/instance"  = "argocd"
      "app.kubernetes.io/name"      = "argocd-server"
    }
  }
}

# Wait for ArgoCD to be fully ready
resource "time_sleep" "wait_for_argocd" {
  depends_on = [
    helm_release.argocd,
    kubernetes_service.argocd_server_nodeport
  ]
  create_duration = "90s"
}

# Data source to get ArgoCD admin password
data "kubernetes_secret" "argocd_initial_admin_secret" {
  depends_on = [time_sleep.wait_for_argocd]
  
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
}
