resource "random_password" "prometheus_api" {
  length  = 16
  special = false
}

resource "kubectl_manifest" "prometheus_api" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
  namespace: prometheus
type: Opaque
data:
  auth: ${base64encode("${var.api_username}:${bcrypt(random_password.prometheus_api.result)}")}
YAML

  lifecycle {
    ignore_changes = [yaml_body]
  }
}
