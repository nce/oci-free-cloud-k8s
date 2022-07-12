variable "vault_id" {
  description = "OCI Vault OIDC"
  type        = string
}

variable "compartment_id" {
  description = "The compartment to create the resources in"
  type        = string
}

variable "ui_username" {
  description = "Username for the web ui"
  type        = string

  default = "storage"
}
