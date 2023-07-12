output "prometheus_api_login" {
  value = "${var.api_username} : ${random_password.prometheus_api.result}"

  sensitive = true
}
