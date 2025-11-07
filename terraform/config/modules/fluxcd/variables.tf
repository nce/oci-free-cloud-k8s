variable "gh_token" {
  sensitive = true
  type      = string
}

variable "gh_org" {
  type = string

  default = "nce"
}

variable "gh_repository" {
  type = string

  default = "oci-free-cloud-k8s"
}

variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
  default     = ""
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
  default     = ""
}

variable "github_app_pem" {
  description = "The contents of the GitHub App private key PEM file"
  sensitive   = true
  type        = string
  default     = ""
}

variable "git_url" {
  description = "Git repository URL"
  type        = string
  nullable    = false

  default = "https://github.com/jdanieu/oci-free-cloud-k8s.git"
}

variable "flux_version" {
  description = "Flux version semver range"
  type        = string
  default     = "2.x"
}

variable "flux_registry" {
  description = "Flux distribution registry"
  type        = string
  default     = "ghcr.io/fluxcd"
}
