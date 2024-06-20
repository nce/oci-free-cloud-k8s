module "externalsecrets" {
  source = "./modules/external-secrets"

  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  vault_id       = var.vault_id

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

module "externaldns" {
  source = "./modules/external-dns"

  compartment_id = var.compartment_id
}

module "homelab" {
  source = "./modules/homelab"

  group_id       = module.externaldns.dns_group_id
  compartment_id = var.compartment_id
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
