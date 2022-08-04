resource "kubectl_manifest" "lychee_ingress" {

  depends_on = [
    kubectl_manifest.lychee_namespace
  ]

  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: lychee-ingress
  namespace: lychee
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    acme.cert-manager.io/http01-edit-in-place: "true"
    kubernetes.io/ingress.class: nginx
    external-dns.alpha.kubernetes.io/hostname: img.nce.wtf
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
spec:
  tls:
  - hosts:
      - img.nce.wtf
    secretName: lychee-cert
  rules:
  - host: img.nce.wtf
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: lychee-service
            port:
              name: http
YAML
}
