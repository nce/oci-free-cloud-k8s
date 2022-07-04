resource "random_password" "dex_grafana_client" {
  length  = 16
  special = false
}

resource "kubectl_manifest" "dex_grafana_client" {

  depends_on = [
    helm_release.grafana
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: dex-grafana-client
  namespace: grafana
type: Opaque
data:
  client-id: ${base64encode("grafana")}
  client-secret: ${base64encode(random_password.dex_grafana_client.result)}
YAML
}

resource "kubectl_manifest" "dex_grafana_dex_client" {

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: dex-grafana-client
  namespace: dex
type: Opaque
data:
  grafana.client-id: ${base64encode("grafana")}
  grafana.client-secret: ${base64encode(random_password.dex_grafana_client.result)}
YAML
}
