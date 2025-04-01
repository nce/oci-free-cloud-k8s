data "github_repository" "oci" {
  full_name = "${var.gh_org}/${var.gh_repository}"
}

resource "random_password" "webhook_secret" {
  length  = 32
  special = false
}

data "oci_kms_vaults" "existing_vault" {
  compartment_id = var.compartment_id
}

data "oci_kms_keys" "existing_key" {
  compartment_id      = var.compartment_id
  management_endpoint = data.oci_kms_vaults.existing_vault.vaults[0].management_endpoint
}

resource "oci_vault_secret" "test_secret" {
  #Required
  compartment_id = var.compartment_id
  key_id         = data.oci_kms_keys.existing_key.keys[0].id
  secret_name    = "github-flux-webhook-token"
  vault_id       = data.oci_kms_vaults.existing_vault.vaults[0].id

  secret_content {
    name         = "token"
    content_type = "BASE64"
    content      = base64encode(random_password.webhook_secret.result)
  }
}

resource "github_repository_webhook" "flux_webhook" {
  repository = data.github_repository.oci.name

  configuration {
    url          = "https://flux-webhook.nce.wtf/hook/${sha256(format("%s%s%s", random_password.webhook_secret.result, "github-receiver", "flux-system"))}"
    content_type = "json"
    secret       = random_password.webhook_secret.result
    insecure_ssl = false
  }

  events = ["push"]
}
