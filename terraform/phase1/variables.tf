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


