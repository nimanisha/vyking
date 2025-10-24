resource "null_resource" "helm_repo_add" {
  provisioner "local-exec" {
    command = "helm repo add argo https://argoproj.github.io/argo-helm || true && helm repo update"
  }
  
  triggers = {
    repo_url = "https://argoproj.github.io/argo-helm"
  }
}

resource "time_sleep" "wait_for_repo" {
  depends_on = [null_resource.helm_repo_add]
  create_duration = "10s"
}