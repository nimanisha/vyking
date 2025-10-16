output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = try(base64decode(data.kubernetes_secret.argocd_initial_admin_secret.data.password), "Password not ready yet")
  sensitive   = true
}

output "argocd_server_url" {
  description = "ArgoCD server URL"
  value       = "http://localhost:30080"
}

output "cluster_info" {
  description = "K3D cluster information"
  value = {
    cluster_name = var.cluster_name
    context      = "k3d-${var.cluster_name}"
    namespace    = kubernetes_namespace.argocd.metadata[0].name
  }
}
