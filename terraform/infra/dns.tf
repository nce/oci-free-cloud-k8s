resource "oci_dns_zone" "main_zone" {
  compartment_id = var.compartment_id
  name           = var.dns_domain_name
  zone_type      = "PRIMARY"

}
