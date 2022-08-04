resource "kubectl_manifest" "lychee_service" {

  depends_on = [
    kubectl_manifest.lychee_namespace
  ]

  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: lychee-service
  namespace: lychee
spec:
  selector:
    app.kubernetes.io/name: lychee
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: http
YAML
}
