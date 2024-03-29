module "externalsecrets" {
  source = "./modules/external-secrets"

  compartment_id = var.compartment_id
  vault_id       = var.vault_id
  tenancy_id     = var.tenancy_id

  depends_on = [
    module.fluxcd
  ]
}

module "fluxcd" {
  source = "./modules/fluxcd"

  gh_token = var.gh_token
}

module "ingress" {
  source = "./modules/nginx-ingress"

  compartment_id = var.compartment_id
}

module "certmanager" {
  source = "./modules/cert-manager"
}

module "externaldns" {
  source = "./modules/external-dns"

  compartment_id = var.compartment_id
}

module "dex" {
  source = "./modules/dex"
}

module "argocd" {
  source = "./modules/argocd"
}

module "prometheus" {
  source = "./modules/prometheus"
}

module "grafana" {
  source = "./modules/grafana"

  compartment_id = var.compartment_id
}

module "longhorn" {
  source = "./modules/longhorn"

  compartment_id = var.compartment_id
  vault_id       = var.vault_id
}

module "lychee" {
  source = "./modules/lychee"
}
