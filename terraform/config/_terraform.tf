terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 4"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.13"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
  }
}
