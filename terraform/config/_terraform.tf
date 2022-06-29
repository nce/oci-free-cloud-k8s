terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 4"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3"
    }
  }
}
