locals {
  cluster_config_path = var.kubeconfig
}

provider "kubernetes" {
  config_path    = local.cluster_config_path
  config_context = var.kube_context
}
