provider "github" {
  owner = var.gh_org
  token = var.gh_token
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = var.gh_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

provider "flux" {

  kubernetes = {
    config_path = "~/.kube/oci.kubeconfig"
  }

  git = {
    url = "ssh://git@github.com/${var.gh_org}/${var.gh_repository}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this]

  path = "gitops/oci"
}
