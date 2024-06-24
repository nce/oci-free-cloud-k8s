# https://go-acme.github.io/lego/dns/oraclecloud/
# OCI_PRIVKEY_FILE="~/.oci/oci_api_key.pem" \
# OCI_PRIVKEY_PASS="secret" \
# OCI_TENANCY_OCID="ocid1.tenancy.oc1..secret" \
# OCI_USER_OCID="ocid1.user.oc1..secret" \
# OCI_PUBKEY_FINGERPRINT="00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00" \
# OCI_REGION="us-phoenix-1" \
# OCI_COMPARTMENT_OCID="ocid1.tenancy.oc1..secret" \

output "dns_privkey" {
  value = tls_private_key.homelab.private_key_pem
}

output "dns_tenancy" {
  value = var.compartment_id
}

output "dns_user" {
  value = oci_identity_user.homelab.id
}

output "dns_api_fingerprint" {
  value = oci_identity_api_key.homelab.fingerprint
}
