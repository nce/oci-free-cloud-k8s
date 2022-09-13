resource "helm_release" "prometheus" {
  chart      = "kube-prometheus-stack"
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "39.13.0"
  namespace  = "prometheus"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 120

  values = [<<YAML
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
