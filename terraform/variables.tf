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