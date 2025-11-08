resource "kubectl_manifest" "external_secrets_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: external-secrets
YAML
}

resource "kubectl_manifest" "external_secrets_api_secret" {
  depends_on = [kubectl_manifest.external_secrets_namespace]
  
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: home-vault
  namespace: external-secrets
type: Opaque
data:
  privateKey: ${base64encode(var.external_secrets_api_private_key_pem)}
  fingerprint: ${base64encode(var.external_secrets_api_fingerprint)}
YAML
}

resource "kubectl_manifest" "external_secrets_cluster_store" {
  depends_on = [kubectl_manifest.external_secrets_api_secret]
  
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: home-vault
spec:
  provider:
    oracle:
      vault: ${var.vault_id}
      region: ${var.vault_region}
      auth:
        user: ${var.external_secrets_user_id}
        tenancy: ${var.tenancy_id}
        principalType: UserPrincipal
        secretRef:
          privatekey:
            name: home-vault
            key: privateKey
            namespace: external-secrets
          fingerprint:
            name: home-vault
            key: fingerprint
            namespace: external-secrets
YAML
}
