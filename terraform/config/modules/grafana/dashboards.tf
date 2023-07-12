resource "kubernetes_manifest" "solar_dashboard" {
  manifest = yamldecode(templatefile("${path.module}/templates/dashboard-solar-configmap.yaml", {
   name      = "grafana-solar"
   data      = file("${path.module}/dashboards/solar-dashboard.json")
  }))
}
