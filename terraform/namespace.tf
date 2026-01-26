resource "kubernetes_namespace" "db" {
  metadata {
    name = "db"
  }
}

resource "kubernetes_namespace" "backend" {
  metadata {
    name = "backend"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}