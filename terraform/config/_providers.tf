provider "kubectl" {
  load_config_file = true
  config_path      = "~/.kube/configs/oci.kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/configs/oci.kubeconfig"
  }
}
