variable "compartment_id" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "chart_version" {
  type        = string
  description = "Nginx Helm Chart version"
}
