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
  }
}

# Configure Kubernetes provider for K3D cluster
provider "kubernetes" {
  # config_path is not needed if not using a specific Kube config file
  config_context = "k3d-${var.cluster_name}"
}

# Configure Helm provider for K3D cluster
provider "helm" {
  kubernetes {
    # config_path is not needed here either
    config_context = "k3d-${var.cluster_name}"
  }
}

# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      name = var.argocd_namespace
      "app.kubernetes.io/name" = "argocd"
    }
  }
}

# Ensure default namespace exists
resource "kubernetes_namespace" "default" {
  metadata {
    name = var.application_namespace
  }
  
  # Prevent destruction of default namespace
  lifecycle {
    prevent_destroy = true
  }
}
