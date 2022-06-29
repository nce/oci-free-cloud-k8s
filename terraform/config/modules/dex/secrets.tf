resource "kubectl_manifest" "dex_github_secet" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: dex-github-connector
  namespace: dex
type: Opaque
data:
  GITHUB_CLIENT_ID: ${data.oci_secrets_secretbundle.github_client_id.secret_bundle_content.0.content}
  GITHUB_CLIENT_SECRET: ${data.oci_secrets_secretbundle.github_client_secret.secret_bundle_content.0.content}
YAML
}
