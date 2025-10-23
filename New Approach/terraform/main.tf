# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "argo"
#   chart            = "argo-cd"
#   namespace        = "argocd"
#   create_namespace = true

#   values = [<<EOF
# server:
#   service:
#     type: ClusterIP
#   extraArgs:
#     - --insecure
# EOF
#   ]

#   depends_on = [time_sleep.wait_for_repo]
# }

# Wait for ArgoCD CRDs to be ready
resource "time_sleep" "wait_for_argocd_crds" {
  # depends_on = [helm_release.argocd]
  create_duration = "5s"
}

# Verify CRDs are installed
resource "null_resource" "verify_argocd_crds" {
  depends_on = [time_sleep.wait_for_argocd_crds]
  
  provisioner "local-exec" {
    command = "kubectl get crd applications.argoproj.io"
    interpreter = ["cmd", "/C"]
  }
  
  provisioner "local-exec" {
    command = "kubectl wait --for condition=established --timeout=300s crd/applications.argoproj.io"
    interpreter = ["cmd", "/C"]
  }
}

resource "kubernetes_manifest" "argocd_app_infra" {
  manifest = yamldecode(templatefile(
    "${path.module}/argocd-apps/infra-application.yaml.tpl",
    {
      repo_url    = var.repo_url
      repo_branch = var.repo_branch
    }
  ))
  
  depends_on = [null_resource.verify_argocd_crds]
}

resource "kubernetes_manifest" "argocd_app_apps" {
  manifest = yamldecode(templatefile(
    "${path.module}/argocd-apps/apps-application.yaml.tpl",
    {
      repo_url    = var.repo_url
      repo_branch = var.repo_branch
    }
  ))
  
  depends_on = [null_resource.verify_argocd_crds]
}