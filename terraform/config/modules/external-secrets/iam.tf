resource "oci_identity_group" "vault_admin" {
  compartment_id = var.compartment_id
  description    = "VaultAdmins"
  name           = "VaultAdmins"
}

resource "oci_identity_user" "external_secrets" {
  compartment_id = var.compartment_id
  description    = "ExternalSecrets"
  name           = "ExternalSecrets"
  email          = "770135+nce@users.noreply.github.com"
}

resource "tls_private_key" "external_secrets" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "oci_identity_api_key" "external_secrets" {
  key_value = tls_private_key.external_secrets.public_key_pem
  user_id   = oci_identity_user.external_secrets.id
}

resource "oci_identity_user_group_membership" "user_group_membership" {
  group_id = oci_identity_group.vault_admin.id
  user_id  = oci_identity_user.external_secrets.id
}

resource "oci_identity_user_capabilities_management" "user_capabilities_management" {
  user_id = oci_identity_user.external_secrets.id

  can_use_api_keys = "true"
}

resource "oci_identity_policy" "external_secrets" {
  compartment_id = var.compartment_id
  description    = "allow vault management"
  name           = "VaultAdmins"
  statements = [
    "Allow group 'Default'/'VaultAdmins' to manage secret-family in tenancy",
    "Allow group 'Default'/'VaultAdmins' to manage vault in tenancy"
  ]
}
