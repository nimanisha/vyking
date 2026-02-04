variable "dockerconfigjson" {
  description = "GitHub token for my account"
  type = string
  sensitive = true
  # default = """
  
}
variable "postgres_password" {
  description = "DB Password"
  type = string
  sensitive = true
  # default = ""
  
}


