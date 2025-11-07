terraform {

  # this requires tf >=1.12
  # see previous versions of this file for backwards compatibilyt
  backend "oci" {
    namespace = "ax7cfee9ogw3"
    bucket    = "terraform-states"
    key       = "config/terraform.tfstate"
  }

  required_providers {
    oci = {
      source = "oracle/oci"
      version = "~> 7.24.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1"
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
