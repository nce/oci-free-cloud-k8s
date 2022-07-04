resource "random_password" "dex_argocd_client" {
  length  = 16
  special = false
}

resource "kubectl_manifest" "dex_argocd_client" {
  depends_on = [
    helm_release.argocd
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: dex-argocd-client
  namespace: argocd
  labels:
    app.kubernetes.io/part-of: argocd
type: Opaque
data:
  client-id: ${base64encode("argo")}
  client-secret: ${base64encode(random_password.dex_argocd_client.result)}
YAML
}

resource "kubectl_manifest" "dex_argocd_dex_client" {

  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: dex-argocd-client
  namespace: dex
type: Opaque
data:
  client-id: ${base64encode("argo")}
  client-secret: ${base64encode(random_password.dex_argocd_client.result)}
YAML
}
