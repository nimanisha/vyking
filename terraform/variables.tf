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