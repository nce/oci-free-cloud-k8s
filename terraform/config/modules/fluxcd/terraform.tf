terraform {

  required_providers {

    flux = {
      source = "fluxcd/flux"
    }

    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
  }
}
