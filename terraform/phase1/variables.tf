# variable "db_password" {
#   description = "The password for the PostgreSQL root user"
#   type        = string
#   sensitive   = true
#   default     = ""
# }

# variable "db_name" {
#   description = "Name of the initial database"
#   type        = string
#   default     = "postgres "
# }

# variable "postgres_version" {
#   description = "Helm chart version for PostgreSQL"
#   type        = string
#   default     = "18.2.0"
# }
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
# variable "namespace" {
#   type = string  
# }
