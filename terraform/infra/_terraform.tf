terraform {

  backend "s3" {
    bucket = "terraform-states"
    key    = "infra/terraform.tfstate"
    endpoints = {
      s3 = "https://frrwy4uskhkj.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    }
    region                      = "eu-frankfurt-1"
    shared_credentials_files    = ["~/.oci/config"]
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style              = true
  }

  required_providers {
    jq = {
      source  = "massdriver-cloud/jq"
      version = "0.2.1"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 6.35.0"
    }
  }
}
