module "phase0" {
  source            = "./phase0"
}
module "phase1" {
  source            = "./phase1"
  postgres_password = var.postgres_password
  dockerconfigjson = var.dockerconfigjson
  depends_on       = [module.phase0]
}

module "phase2" {
  source           = "./phase2"
  count            = var.deploy_phase2 ? 1 : 0 
  depends_on       = [module.phase1]
}