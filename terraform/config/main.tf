module "certmanager" {
  source = "./modules/cert-manager"

  chart_version = var.cert_manager_version

}
