variable "kubeconfig_path" {
  type    = string
  default = "C:/Users/Nima/kubeconfig.yaml"
}

variable "repo_url" {
  type = string
  default = "https://github.com/nimanisha/vyking.git"
}

variable "repo_branch" {
  type    = string
  default = "main"
}

variable "argocd_namespace" {
  description = "Namespace where ArgoCD will be installed"
  type        = string
  default     = "argocd"
}