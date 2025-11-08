variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "vault_id" {
  type        = string
  description = "The OCID of the Vault to store the secrets in"
}

variable "tenancy_id" {
  type        = string
  description = "The OCID of the tenancy"
}

variable "external_secrets_user_id" {
  type        = string
  description = "The OCID of the External Secrets user"
}

variable "external_secrets_api_fingerprint" {
  type        = string
  description = "The fingerprint of the External Secrets API key"
}

variable "external_secrets_api_private_key_pem" {
  type        = string
  sensitive   = true
  description = "The private key PEM for External Secrets API authentication"
}

variable "vault_region" {
  type        = string
  description = "The region where the vault is located"
}
