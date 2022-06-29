resource "kubectl_manifest" "deploy_echo" {

  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo1
spec:
  selector:
    matchLabels:
      app: echo1
  replicas: 2
  template:
    metadata:
      labels:
        app: echo1
    spec:
      containers:
      - name: echo1
        image: ealen/echo-server:latest
        env:
        - name: PORT
          value: "5678"
        ports:
        - containerPort: 5678
YAML
}

resource "kubectl_manifest" "service_echo" {

  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: echo1
spec:
  ports:
  - port: 80
    targetPort: 5678
  selector:
    app: echo1
YAML
}

resource "kubectl_manifest" "ingress_echo" {

  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
    acme.cert-manager.io/http01-edit-in-place: "true"
    kubernetes.io/ingress.class: nginx
    external-dns.alpha.kubernetes.io/hostname: echo.klangregen.de
spec:
  rules:
  - host: echo.klangregen.de
    http:
      paths:
        - pathType: Prefix
          path: "/"
          backend:
            service:
              name: echo1
              port:
                number: 80
  tls:
  - hosts:
    - echo.klangregen.de
    secretName: echo-cert
YAML
}
