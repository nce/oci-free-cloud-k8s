resource "helm_release" "prometheus" {
  chart      = "kube-prometheus-stack"
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "52.1.0"
  namespace  = "prometheus"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 120

  values = [<<YAML
prometheus:
  ingress:
    enabled: true
    hosts: 
      - prometheus.klangregen.de
    tls:
    - secretName: prometheus-cert
      hosts:
        - prometheus.klangregen.de
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt
      acme.cert-manager.io/http01-edit-in-place: "true"
      kubernetes.io/ingress.class: nginx
      external-dns.alpha.kubernetes.io/hostname: prometheus.klangregen.de
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: basic-auth
      nginx.ingress.kubernetes.io/auth-realm: "Enter your credentials"
  prometheusSpec:
    enableRemoteWriteReceiver: true
    retention: ""
    retentionSize: 14GB
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: longhorn
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 15Gi
grafana:
  enabled: false
  forceDeployDashboards: true
  namespaceOverride: grafana
  forceDeployDatasources: true
alertmanager:
  extraSecret:
    name: slack-connection
    data:
      slack: ${base64decode(data.oci_secrets_secretbundle.slack_workspace_id.secret_bundle_content.0.content)}
  alertmanagerSpec:
   name: alertmanager-config
YAML
  ]
}
