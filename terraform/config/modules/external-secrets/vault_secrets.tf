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

data "oci_kms_vaults" "external_secrets_vault" {
  compartment_id = var.compartment_id

  filter {
    name   = "id"
    values = [var.vault_id]
  }
}

data "oci_kms_keys" "external_secrets_key" {
  compartment_id      = var.compartment_id
  management_endpoint = data.oci_kms_vaults.external_secrets_vault.vaults[0].management_endpoint
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
      compartment: ${var.compartment_id}
      encryptionKey: ${coalesce(var.vault_key_id, data.oci_kms_keys.external_secrets_key.keys[0].id)}
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
