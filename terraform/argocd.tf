resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = false

  wait = true

  depends_on = [kubernetes_secret.ghcr-login_backend]
}

data "kubernetes_secret" "argocd_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}
resource "argocd_repository" "ghcr_oci" {
  repo     = "ghcr.io/nimanisha/charts" 
  name     = "backend-oci"
  type     = "helm"
  enable_oci = true
  username = "nimanisha"
  password = var.dockerconfigjson 

  depends_on = [kubernetes_secret.argocd_admin_secret]
}

resource "null_resource" "apply_argocd_apps" {
  depends_on = [
    helm_release.argocd,
    kubernetes_secret.my-db-postgresql_backend, argocd_repository.ghcr_oci
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ../Argocd/infra-app.yaml"    
    environment = {
      KUBECONFIG = "~/.kube/config"
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ../Argocd/infra-app.yaml --ignore-not-found"
  }
}
resource "null_resource" "apply_backend_apps" {
  depends_on = [
    null_resource.apply_argocd_apps
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ../Argocd/backend-app.yaml"    
    environment = {
      KUBECONFIG = "~/.kube/config"
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ../Argocd/backend-app.yaml --ignore-not-found"
  }
}
resource "null_resource" "apply_frontend_apps" {
  depends_on = [
    null_resource.apply_backend_apps
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ../Argocd/frontend-app.yaml"    
    environment = {
      KUBECONFIG = "~/.kube/config"
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ../Argocd/frontend-app.yaml --ignore-not-found"
  }
}