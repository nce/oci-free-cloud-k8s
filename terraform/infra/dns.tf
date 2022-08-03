resource "oci_dns_zone" "klangregen_zone" {
  compartment_id = var.compartment_id
  name           = var.klangregen_domain_name
  zone_type      = "PRIMARY"
}

resource "oci_dns_zone" "wtf_zone" {
  compartment_id = var.compartment_id
  name           = var.wtf_domain_name
  zone_type      = "PRIMARY"
}
