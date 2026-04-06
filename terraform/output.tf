output "final_cluster_name" {
  value = module.phase0.cluster_name_out
}

output "argocd_initial_password" {
  description = "The initial admin password for ArgoCD"
  value       = module.phase1.argocd_password
  sensitive   = true
}

