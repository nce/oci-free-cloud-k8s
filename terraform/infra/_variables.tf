variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "region" {
  description = "OCI region"
  type        = string

  default = "eu-frankfurt-1"
}

variable "ssh_public_key" {
  description = "SSH Public Key used to access all instances"
  type        = string

  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBPjsPbPbEsCywcFfS24iBUV1ISMM+5Yk0eqWuaNSP8YqjgPkJU5K62Pm8tRYUpfoP2mkF5zdT3Zj+6kMtqxkACcvQDui71PzIVQx57AE4wcvsEYXqLYNpvHl/YEdf7fCNvsXounnJjYSHbjRPjTcq+34CgedCVFL5MYXpdRmc5Kl1Do8JscYm5AzVOhfRJJ0Fiqd4bkRMpJN5zYZ+NYw/cnSKFckSTsG4pSbcSCoR1wPNRU6rEPXSQa2hFZPpYORuxKcwua/bb3aRzyU1fT7xdjzkDs++0rQJQ461kvBjsYgD5Zuwgl3MkzouVx2p5ic1dU34kQTrWpH3z5diRut7 ull@rsa"
}

variable "kubernetes_version" {
  # https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengaboutk8sversions.htm
  description = "Version of Kubernetes"
  type        = string

  default = "v1.23.4"
}

# TODO: search for latest image
variable "image_id" {
  # https://docs.oracle.com/en-us/iaas/images/all/?search=aarch64
  description = "OCID of the latest oracle linux"
  type        = string

  default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaxp2zqotv37r4zycmwfqywcujsh4scenphjjs5w2ozakmidg3vs6q"
}

variable "dns_domain_name" {
  description = "Main DNS Zone"
  type        = string

  default = "klangregen.de"
}
