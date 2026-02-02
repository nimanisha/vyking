module "base" {
  source            = "./modules/phase1_base"
  postgres_password = var.postgres_password
}

module "apps" {
  source           = "./modules/phase2_argocd"
  count            = var.deploy_phase2 ? 1 : 0 
  dockerconfigjson = var.dockerconfigjson
  depends_on       = [module.base]
}