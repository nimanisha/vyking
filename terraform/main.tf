module "phase1" {
  source            = "./phase1"
  postgres_password = var.postgres_password
  dockerconfigjson = var.dockerconfigjson
  # cluster_name = var.cluster_name
}

module "phase2" {
  source           = "./phase2"
  count            = var.deploy_phase2 ? 1 : 0 
  depends_on       = [module.phase1]
}