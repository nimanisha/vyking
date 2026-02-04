output "argocd_initial_password" {
  description = "The initial admin password for ArgoCD"
  value       = module.phase1.argocd_password
  sensitive   = true
}