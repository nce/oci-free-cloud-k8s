resource "oci_dns_rrset" "wildcard" {
  domain = "*.home.nce.wtf"
  rtype = "A"
  zone_name_or_id = "nce.wtf"

  items {
      domain = "*.home.nce.wtf"
      rdata = "192.168.1.221"
      rtype = "A"
      ttl = "300"
  }
}

resource "oci_dns_rrset" "homelab" {
  domain = "home.nce.wtf"
  rtype = "A"
  zone_name_or_id = "nce.wtf"

  items {
      domain = "home.nce.wtf"
      rdata = "192.168.1.221"
      rtype = "A"
      ttl = "300"
  }
}
