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
