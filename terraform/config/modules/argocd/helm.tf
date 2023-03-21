resource "helm_release" "argocd" {
  chart      = "argo-cd"
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "5.27.1"
  namespace  = "argocd"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 70

  values = [<<YAML
dex:
  enabled: false
server:
  repositories: |
    - type: git
      url: https://github.com/nce/oci-free-cloud-k8s.git
  config:
    # Argo CD's externally facing base URL (optional). Required when configuring SSO
    url: https://argocd.klangregen.de
    application.instanceLabelKey: argocd.argoproj.io/instance

    oidc.config: |
      name: Github
      issuer: https://login.klangregen.de/dex/
      clientID: $dex-argocd-client:client-id
      clientSecret: $dex-argocd-client:client-secret
      requestedIDTokenClaims:
        groups:
          essential: true
      requestedScopes:
        - openid
        - email
        - profile
        - groups
  rbacConfig:
    policy.csv: |
      g, nce-acme:admin, role:admin
      g, nce-acme:zuschauer, role:readonly
  extraArgs:
    - --insecure
  service:
    type: "NodePort"
  ingress:
    enabled: true
    hosts:
      - argocd.klangregen.de
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt
      acme.cert-manager.io/http01-edit-in-place: "true"
      kubernetes.io/ingress.class: nginx
      external-dns.alpha.kubernetes.io/hostname: argocd.klangregen.de
    tls:
      - hosts:
        - argocd.klangregen.de
        secretName: argocd-cert
YAML
  ]
}
