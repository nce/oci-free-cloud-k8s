data "oci_secrets_secretbundle" "github_client_id" {
  secret_id = "ocid1.vaultsecret.oc1.eu-frankfurt-1.amaaaaaasuzlxsiajf6zjoihbjohe3eggn4du4vv5mpwa5vszl6iynqspvaq"
}

data "oci_secrets_secretbundle" "github_client_secret" {
  secret_id = "ocid1.vaultsecret.oc1.eu-frankfurt-1.amaaaaaasuzlxsiacbthpsoukzm3ktx5owowfcfdzybrhzkjckf7hrsus5nq"
}
