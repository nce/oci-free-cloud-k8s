resource "random_password" "longhorn_ui" {
  length  = 16
  special = false
}

resource "kubectl_manifest" "longhorn_ui" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
  namespace: longhorn-system
type: Opaque
data:
  auth: ${base64encode("${var.ui_username}:${bcrypt(random_password.longhorn_ui.result)}")}
YAML

  lifecycle {
    ignore_changes = [yaml_body]
  }
}
