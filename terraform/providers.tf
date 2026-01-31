terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "6.1.1" 
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
provider "argocd" {

  server_addr = "localhost:8080" 
  insecure    = true
  username    = "admin"
  password    = data.kubernetes_secret.argocd_admin_secret.data["password"]
  port_forward = true
  port_forward_with_namespace = "argocd"
}