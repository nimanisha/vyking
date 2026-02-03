variable "deploy_phase2" {
  type        = bool
  description = "Switch to enable/disable ArgoCD applications deployment"
  default     = false
}
variable "dockerconfigjson" {
  description = "GitHub token for my account"
  type = string
  sensitive = true
  default = "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"
  
}
variable "postgres_password" {
  description = "DB Password"
  type = string
  sensitive = true
  default = "Kia@220995"
  
}
variable "cluster_name" {
    type = string
    default = "gitops-cluster"
}