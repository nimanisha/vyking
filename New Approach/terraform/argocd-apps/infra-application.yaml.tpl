apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: infra
  namespace: argocd
spec:
  project: default
  source:
    repoURL: "${repo_url}"
    targetRevision: "${repo_branch}"
    path: New Approach/infrastructure
    helm:
      valueFiles:
        - values.yaml    
  destination:
    server: https://kubernetes.default.svc
    namespace: infra
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
