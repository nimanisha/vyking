variable "deploy_phase2" {
  type        = bool
  description = "Switch to enable/disable ArgoCD applications deployment"
  default     = false
}
variable "dockerconfigjson" {
  description = "GitHub token for my account"
  type = string
  sensitive = true
  # default = ""
  
}
variable "postgres_password" {
  description = "DB Password"
  type = string
  sensitive = true
  
}
variable "cluster_name" {
    type = string
    default = "gitops-cluster"
}