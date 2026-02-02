module "phase1" {
  source            = "./phase1"
#   postgres_password = var.postgres_password
}

module "phase2" {
  source           = "./phase2"
  count            = var.deploy_phase2 ? 1 : 0 
#   dockerconfigjson = var.dockerconfigjson
  depends_on       = [module.phase1]
}