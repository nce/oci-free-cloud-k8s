resource "kubectl_manifest" "externaldns_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: external-dns
YAML
}

resource "kubectl_manifest" "oci_secret" {
  # https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/oracle.md
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: external-dns-config
  namespace: external-dns
type: Opaque
data:
  oci.yaml: |
    ${indent(6, base64encode(templatefile("${path.module}/files/auth.yaml", {
  compartment_id = var.compartment_id
  user_id        = oci_identity_user.external_dns.id
  private_key    = tls_private_key.external_dns.private_key_pem
  fingerprint    = oci_identity_api_key.external_dns.fingerprint
}
)))}

YAML
}
#compartment: ${base64encode(var.compartment_id)}
