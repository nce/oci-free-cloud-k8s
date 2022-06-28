resource "helm_release" "cert-manager" {
  chart      = "cert-manager"
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = var.chart_version
  namespace  = "cert-manager"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 60

  #  depends_on = [
  #  kubectl_manifest.cert_manager_crds
  #]
  values = [<<YAML
installCRDs: true
YAML
  ]

}
