resource "helm_release" "cert-manager" {
  chart      = "cert-manager"
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "v1.10.0"
  namespace  = "cert-manager"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 60

  values = [<<YAML
installCRDs: true
YAML
  ]

}
