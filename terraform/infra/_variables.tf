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

variable "kubernetes_control_plane_version" {
  # https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengaboutk8sversions.htm
  description = "Version of Kubernetes Control Plane"
  type        = string

  default = "v1.34.1"
}

variable "kubernetes_kubelets_version" {
  # https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengaboutk8sversions.htm
  description = "Version of Kubernetes Kubelet"
  type        = string

  default = "v1.34.1"
}


variable "kubernetes_worker_nodes" {
  description = "Worker node count"
  type        = number

  default = 2
}

# Optional: Only needed if not using ~/.oci/config
# variable "tenancy_ocid" {
#   description = "OCI Tenancy OCID"
#   type        = string
# }
# 
# variable "user_ocid" {
#   description = "OCI User OCID (your personal user, not external-secrets)"
#   type        = string
# }
# 
# variable "fingerprint" {
#   description = "Fingerprint for your OCI API key"
#   type        = string
# }
# 
# variable "private_key_path" {
#   description = "Path to your OCI private key"
#   type        = string
#   default     = "~/.oci/oci_api_key.pem"
# }
