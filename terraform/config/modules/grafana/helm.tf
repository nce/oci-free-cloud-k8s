resource "helm_release" "grafana" {
  chart      = "grafana"
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  version    = "6.31.1"
  namespace  = "grafana"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 70

  values = [<<YAML
grafana.ini:
  app_mode: production
  server:
    domain: monitoring.klangregen.de
    root_url: https://monitoring.klangregen.de

  users:
    allow_sign_up: false

  auth:
    disable_login_form: true
  auth.generic_oauth:
    enabled: true
    name: Dex
    allow_sign_up: true
    client_id: some_id
    client_secret: some_secret
    scopes: openid profile email groups
    ;empty_scopes: false
    email_attribute_path: email
    ;id_token_attribute_name:
    auth_url: https://login.klangregen.de/dex/auth
    token_url: https://login.klangregen.de/dex/token
    api_url: https://login.klangregen.de/dex/userinfo

ingress:
  enabled: true
  hosts:
    - monitoring.klangregen.de
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    acme.cert-manager.io/http01-edit-in-place: "true"
    kubernetes.io/ingress.class: nginx
    external-dns.alpha.kubernetes.io/hostname: monitoring.klangregen.de
  tls:
    - hosts:
      - monitoring.klangregen.de
      secretName: grafana-cert

YAML
  ]
}
