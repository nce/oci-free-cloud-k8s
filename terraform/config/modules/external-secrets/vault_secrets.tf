resource "kubectl_manifest" "external_secrets_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: external-secrets
YAML
}

resource "kubectl_manifest" "external_secrets_api_secret" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: oracle-vault
  namespace: external-secrets
type: Opaque
data:
  privateKey: ${base64encode(tls_private_key.external_secrets.private_key_pem)}
  fingerprint: ${base64encode(oci_identity_api_key.external_secrets.fingerprint)}
YAML
}

resource "kubectl_manifest" "external_secrets_cluster_store" {
  yaml_body = <<YAML
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: oracle-vault
spec:
  provider:
    oracle:
      vault: ${var.vault_id}
      region: eu-frankfurt-1
      auth:
        user: ${oci_identity_user.external_secrets.id}
        tenancy: ${var.tenancy_id}
        principalType: UserPrincipal
        secretRef:
          privatekey:
            name: oracle-vault
            key: privateKey
            namespace: external-secrets
          fingerprint:
            name: oracle-vault
            key: fingerprint
            namespace: external-secrets
YAML
}
