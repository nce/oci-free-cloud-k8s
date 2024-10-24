# output "longhorn_login" {
#   value = module.longhorn.longhorn_login
#
#   sensitive = true
# }

output "homelab_dns_key" {
  value = module.homelab.dns_privkey

  sensitive = true
}

output "homelab_dns_tenancy" {
  value = module.homelab.dns_tenancy

  sensitive = true
}

output "homelab_dns_user" {
  value = module.homelab.dns_user

  sensitive = true
}

output "homelab_dns_api_fingerprint" {
  value = module.homelab.dns_api_fingerprint

  sensitive = true
}
