resource "helm_release" "longhorn" {
  chart      = "longhorn"
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  version    = "v1.3.0"
  namespace  = "longhorn-system"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 110

  values = [<<YAML
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

YAML
  ]
}
