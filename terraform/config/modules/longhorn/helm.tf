resource "helm_release" "longhorn" {
  chart      = "longhorn"
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  version    = "1.3.2"
  namespace  = "longhorn-system"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 110

  values = [<<YAML
defaultSettings:
  storageMinimalAvailablePercentage: 10
persistence:
  defaultClassReplicaCount: 2
ingress:
  enabled: true
  tls: true
  host: storage.klangregen.de
  tlsSecret: longhorn-cert
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    acme.cert-manager.io/http01-edit-in-place: "true"
    kubernetes.io/ingress.class: nginx
    external-dns.alpha.kubernetes.io/hostname: storage.klangregen.de
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: "Enter your credentials"
YAML
  ]

  depends_on = [
    kubectl_manifest.longhorn_ui
  ]
}
