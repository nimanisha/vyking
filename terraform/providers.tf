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
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
    config_context = "k3d-${var.cluster_name}" 
  }

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "k3d-${var.cluster_name}"
  }
}

