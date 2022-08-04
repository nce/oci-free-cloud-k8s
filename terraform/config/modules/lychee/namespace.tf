resource "kubectl_manifest" "lychee_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: lychee
YAML
}
