# Structure
I decided to split the terraform provisioning in two parts.

* [cluster-infra](infra/) for everything leading to a functioning k8s API, including OCI Vault and External Secrets IAM
* [cluster-config](config/) for everything depending on a k8s API

This way i mitigate long terraform runs and provider dependency.

The infra module outputs several values needed by the config module, including vault credentials for External Secrets operator.

## Environment Variables

Create a `.envrc` file in the `config` directory with the outputs from the `infra` module:

```bash
# From infra outputs
export TF_VAR_compartment_id="ocid1.compartment.oc1...."
export TF_VAR_tenancy_id="ocid1.tenancy.oc1...."
export TF_VAR_public_subnet_id="ocid1.subnet.oc1...."
export TF_VAR_node_pool_id="ocid1.nodepool.oc1...."
export TF_VAR_vault_id="ocid1.vault.oc1...."
export TF_VAR_vault_region="eu-madrid-1"
export TF_VAR_external_secrets_user_id="ocid1.user.oc1...."
export TF_VAR_external_secrets_api_fingerprint="83:a3:86:..."
export TF_VAR_external_secrets_api_private_key_pem="$(terraform -chdir=../infra output -raw external_secrets_api_private_key_pem)"

# GitHub credentials
export TF_VAR_gh_token="$(cat ~/.oci.jdani.eu.github)"
export TF_VAR_gh_org="jdanieu"
export TF_VAR_github_app_id="2248036"
export TF_VAR_github_app_installation_id="93444740"
export TF_VAR_github_app_pem="$(cat ~/.oci.jdani.eu.github_app.pem)"
```

Then run `direnv allow` or `source .envrc` before running terraform.
