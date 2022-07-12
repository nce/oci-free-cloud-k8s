output "longhorn_login" {
  value = "${var.ui_username} : ${random_password.longhorn_ui.result}"

  sensitive = true
}
