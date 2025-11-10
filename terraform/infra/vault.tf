#############################################
# MÓDULO: vault + identidad para External Secrets
# - Sin providers
# - Sin backend
# - Solo locals (sin variables)
#############################################

locals {
  # Nombres y ajustes de KMS
  vault_display_name = "home-vault"
  key_display_name   = "cmk-aes256"
  rotation_days      = 90

  # Identidad para el controlador external-secrets
  ext_user_name        = "external-secrets"
  ext_user_email       = "external-secrets@jdani.eu"
  ext_group_name       = "grp-external-secrets"

  # Current key
  current_extsecrets_api_key = tls_private_key.extsecrets_api_1762775891

  # Tags útiles
  tags = {
    owner = "dani"
    scope = "home"
  }
}

data "oci_identity_compartment" "selected" {
  id = var.compartment_id
}

# Get tenancy information from the compartment
data "oci_identity_tenancy" "current" {
  tenancy_id = data.oci_identity_compartment.selected.compartment_id
}

############################
# Vault (KMS) gestionado por OCI
############################
resource "oci_kms_vault" "vault" {
  compartment_id   = var.compartment_id
  display_name     = local.vault_display_name
  vault_type       = "DEFAULT"

  freeform_tags = local.tags
}

# ############################
# # Clave maestra (CMK) AES-256 en HSM
# ############################
resource "oci_kms_key" "cmk" {
  compartment_id   = var.compartment_id
  display_name     = local.key_display_name
  management_endpoint = oci_kms_vault.vault.management_endpoint
  protection_mode  = "HSM"

  key_shape {
    algorithm = "AES"
    length    = 32  # 256 bits
  }

  lifecycle { prevent_destroy = true }

  freeform_tags = local.tags
}

resource "oci_kms_key_version" "cmk_version" {
  key_id              = oci_kms_key.cmk.id
  management_endpoint = oci_kms_vault.vault.management_endpoint
}


# Key rotation policy is not a separate resource in OCI Terraform provider
# It's configured via the key resource itself or managed through OCI console
# If you need rotation, you can use time_rotating resource or lifecycle rules

############################
# Identidad: usuario + grupo para External Secrets (UserPrincipal)
############################
resource "oci_identity_user" "external_secrets" {
  compartment_id = data.oci_identity_tenancy.current.id  # Use tenancy from data source
  name           = local.ext_user_name
  description    = "UserPrincipal for external-secrets controller"
  email          = local.ext_user_email
  freeform_tags  = local.tags
}

resource "oci_identity_group" "external_secrets" {
  compartment_id = data.oci_identity_tenancy.current.id  # Use tenancy from data source
  name           = local.ext_group_name
  description    = "Group for external-secrets read access to OCI Vault secrets"
  freeform_tags  = local.tags
}

resource "oci_identity_user_group_membership" "external_secrets" {
  user_id  = oci_identity_user.external_secrets.id
  group_id = oci_identity_group.external_secrets.id
}

# Policy mínima: leer bundles de secretos e inspeccionar vaults en el compartment
resource "oci_identity_policy" "vault_read_policy" {
  compartment_id = data.oci_identity_tenancy.current.id
  name        = "eso-vault-read"
  description = "ESO read vault + secrets"
  statements = [
    "Allow group ${oci_identity_group.external_secrets.name} to read vaults in tenancy",
    "Allow group ${oci_identity_group.external_secrets.name} to read secret-family in tenancy", 
  ]
}

############################
# API key RSA para el usuario (fingerprint + private key)
############################
resource "tls_private_key" "extsecrets_api" {
  algorithm = "RSA"
  rsa_bits  = 2048
}


############################
# API key RSA para el usuario (fingerprint + private key)
############################
resource "tls_private_key" "extsecrets_api_1762775891" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "oci_identity_api_key" "extsecrets_api" {
  user_id   = oci_identity_user.external_secrets.id
  key_value = local.current_extsecrets_api_key.public_key_pem
}

############################
# Outputs para ClusterSecretStore
############################
output "vault_id" {
  value = oci_kms_vault.vault.id
}

output "external_secrets_user_id" {
  value = oci_identity_user.external_secrets.id
}

output "external_secrets_api_fingerprint" {
  value = oci_identity_api_key.extsecrets_api.fingerprint
}

# PEM sensible; úsalo solo para crear el Secret en Kubernetes y no lo subas a VCS
output "external_secrets_api_private_key_pem" {
  value     = local.current_extsecrets_api_key.private_key_pem
  sensitive = true
}

output "vault_region" {
  value = var.region
}

output "external_secrets_tenancy_id" {
  value = data.oci_identity_tenancy.current.id
}
