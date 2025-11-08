variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "region" {
  description = "OCI region"
  type        = string

  default = "eu-frankfurt-1"
}

variable "public_subnet_id" {
  type        = string
  description = "The public subnet's OCID"
}

variable "node_pool_id" {
  description = "The OCID of the Node Pool where the compute instances reside"
  type        = string
}

variable "vault_id" {
  description = "OCI Vault OIDC"
  type        = string
}

variable "tenancy_id" {
  description = "Tenancy OCID"
  type        = string
}

variable "gh_token" {
  description = "Github PAT for FluxCD"
  type        = string
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
}

variable "github_app_pem" {
  description = "The contents of the GitHub App private key PEM file"
  sensitive   = true
  type        = string
}

variable "gh_org" {
  description = "Github organization"
  type        = string
}

variable "external_secrets_user_id" {
  description = "External Secrets user OCID"
  type        = string
}

variable "external_secrets_api_fingerprint" {
  description = "External Secrets API key fingerprint"
  type        = string
}

variable "external_secrets_api_private_key_pem" {
  description = "External Secrets API private key PEM"
  type        = string
  sensitive   = true
}

variable "vault_region" {
  description = "Region where the vault is located"
  type        = string
}