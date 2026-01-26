variable "db_password" {
  description = "The password for the PostgreSQL root user"
  type        = string
  sensitive   = true
  default     = "Kia@220995"
}

variable "db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "postgres "
}

variable "postgres_version" {
  description = "Helm chart version for PostgreSQL"
  type        = string
  default     = "18.2.0"
}