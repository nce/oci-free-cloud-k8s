variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "region" {
  description = "OCI region"
  type        = string

  default = "eu-frankfurt-1"
}

variable "public_subnet_id" {
  type        = string
  description = "The public subnet's OCID"
}

variable "node_pool_id" {
  description = "The OCID of the Node Pool where the compute instances reside"
  type        = string
}

variable "nginx_ingress_version" {
  description = "Version of the nginx ingress helm chart"
  type        = string

  default = "4.1.4"
}

variable "cert_manager_version" {
  description = "Version of the cert_manager helm chart"
  type        = string

  default = "v1.8.2"
}

variable "external_dns_version" {
  description = "Version of the external_dns helm chart"
  type        = string

  default = "1.9.0"
}
