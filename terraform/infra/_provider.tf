provider "oci" {
  region = var.region
  # If using the default profile in ~/.oci/config, these are auto-loaded
  # Otherwise, specify them explicitly:
  # tenancy_ocid     = var.tenancy_id
  # user_ocid        = var.user_id
  # fingerprint      = var.fingerprint
  # private_key_path = var.private_key_path
}

provider "tls" {}
