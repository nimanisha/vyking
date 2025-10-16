```hcl
variable "cluster_name" {
  description = "Name of the K3D cluster"
  type        = string
  default     = "vyking"
}

variable "git_repo_url" {
  description = "Git repository URL (HTTPS format for ArgoCD)"
  type        = string
  default     = "https://github.com/nimanisha/vyking.git"
  #   IMPORTANT: Update this with your actual repository URL
}

variable "git_branch" {
  description = "Git branch to sync from"
  type        = string
  default     = "main"
}

variable "argocd_namespace" {
  description = "Namespace where ArgoCD will be installed"
  type        = string
  default     = "argocd"
}

variable "application_namespace" {
  description = "Namespace where applications will be deployed"
  type        = string
  default     = "default"
}

variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"
}
```