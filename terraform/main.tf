resource "null_resource" "k3d_cluster" {
  provisioner "local-exec" {
    command = "k3d cluster create gitops-cluster --api-port 6550 -p '8080:80@loadbalancer' --agents 2 --wait"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete gitops-cluster"
  }
}