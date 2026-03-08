output "argocd_password" {
value     = try(data.kubernetes_secret.argocd_admin_pwd.data["password"], "")
sensitive = true
}