resource "null_resource" "k3d_cluster" {
  provisioner "local-exec" {
    command = "k3d cluster create ${var.cluster_names} --api-port 6550 -p '8080:80@loadbalancer' -p '8443:443@loadbalancer' --agents 2 --k3s-arg '--disable=traefik@server:*' --k3s-arg '--disable=servicelb@server:*' --wait"
  }
  triggers = {
    cluster_name_internal = var.cluster_names
  }
  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete ${self.triggers.cluster_name_internal}"
  }
} 
