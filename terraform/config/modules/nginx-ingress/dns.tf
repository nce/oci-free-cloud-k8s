#data "oci_load_balancer_load_balancers" "nginx_ingress_lb" {
#  #Required
#  compartment_id = var.compartment_id
#
#  depends_on = [
#    helm_release.nginx_ingress
#  ]
#}
#
#output "ingress_external_ip" {
#  value = data.oci_load_balancer_load_balancers.nginx_ingress_lb.load_balancers[0].ip_address_details[0].ip_address
#}
#
#resource "oci_dns_record" "klangregen" {
#  #Required
#  zone_name_or_id = oci_dns_zone_name_or.test_zone_name_or.id
#  domain          = var.record_items_domain
#  rtype           = var.record_items_rtype
#
#  #Optional
#  compartment_id = var.compartment_id
#  rdata          = var.record_items_rdata
#  ttl            = var.record_items_ttl
#}
