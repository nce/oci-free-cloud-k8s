resource "oci_identity_group" "dns_admin" {
  #Required
  compartment_id = var.compartment_id
  description    = "DNSAdmins"
  name           = "DNSAdmins"
}

resource "oci_identity_user" "external_dns" {
  #Required
  compartment_id = var.compartment_id
  description    = "ExternalDNS"
  name           = "ExternalDNS"
  email          = "770135+nce@users.noreply.github.com"
}

resource "tls_private_key" "external_dns" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "oci_identity_api_key" "external_dns" {
  key_value = tls_private_key.external_dns.public_key_pem
  user_id   = oci_identity_user.external_dns.id
}

resource "oci_identity_user_group_membership" "test_user_group_membership" {
  group_id = oci_identity_group.dns_admin.id
  user_id  = oci_identity_user.external_dns.id
}

resource "oci_identity_user_capabilities_management" "test_user_capabilities_management" {
  user_id = oci_identity_user.external_dns.id

  can_use_api_keys = "true"
}

resource "oci_identity_policy" "test_policy" {
  #Required
  compartment_id = var.compartment_id
  description    = "allow dns management"
  name           = "DNSAdmins"
  statements = [
    "Allow group 'Default'/'DNSAdmins' to manage DNS in tenancy"
  ]
}
