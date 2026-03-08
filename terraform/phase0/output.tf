output "cluster_name_out" {
  value      = var.cluster_names
  depends_on = [null_resource.k3d_cluster]
}