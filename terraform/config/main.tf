module "ingress" {
  source = "./modules/nginx-ingress"

  compartment_id = var.compartment_id
  chart_version  = var.nginx_ingress_version
}
module "certmanager" {
  source = "./modules/cert-manager"

  chart_version = var.cert_manager_version
}


