resource "oci_identity_user" "homelab" {
  compartment_id = var.compartment_id
  description    = "Homelab"
  name           = "Homelab"
  email          = "770135+nce@users.noreply.github.com"
}

resource "tls_private_key" "homelab" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "oci_identity_api_key" "homelab" {
  key_value = tls_private_key.homelab.public_key_pem
  user_id   = oci_identity_user.homelab.id
}

resource "oci_identity_user_group_membership" "homelab_user_group_membership" {
  group_id = var.group_id
  user_id  = oci_identity_user.homelab.id
}

resource "oci_identity_user_capabilities_management" "homelab_user_capabilities_management" {
  user_id = oci_identity_user.homelab.id

  can_use_api_keys = "true"
}
