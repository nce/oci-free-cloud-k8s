resource "kubectl_manifest" "alertmanager_config" {
  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: alertmanager-config
  namespace: prometheus
spec:
  route:
    receiver: 'slack'
    groupBy: ['job']
    matchers:
      - name: namespace
        matchType: "=~"
        value: "*"
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 24h
  receivers:
  - name: 'slack'
    slackConfigs:
      - apiURL:
          key: slack
          name: slack-connection
          optional: false
        channel: '#monitoring'

YAML
}
