terraform {
  #backend "http" {

  #  address        = "https://api.tfstate.dev/github/v1"
  #  lock_address   = "https://api.tfstate.dev/github/v1/lock"
  #  unlock_address = "https://api.tfstate.dev/github/v1/lock"
  #  lock_method    = "PUT"
  #  unlock_method  = "DELETE"
  #  username       = "nce/oci-free-cloud-k8s"
  #}

  backend "s3" {
    bucket                      = "terraform-states"
    key                         = "config/terraform.tfstate"
    endpoint                    = "https://frrwy4uskhkj.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    region                      = "eu-frankfurt-1"
    shared_credentials_file     = "~/.oci/config"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.0.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}
