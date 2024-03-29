resource "kubectl_manifest" "lychee_deployment" {

  depends_on = [
    kubectl_manifest.lychee_namespace
  ]

  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lychee
  namespace: lychee
  labels:
    app.kubernetes.io/name: lychee
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: lychee
  template:
    metadata:
      labels:
        app.kubernetes.io/name: lychee
    spec:
      containers:
      - name: lychee
        image: lycheeorg/lychee:v4.4.0
        env:
        - name: PHP_TZ
          value: Europe/Berlin
        - name: APP_URL
          value: "img.nce.wtf"
        - name: PUID
          value: "1000"
        - name: PGID
          value: "1000"
        - name: DB_CONNECTION
          value: sqlite
        - name: DB_DATABASE
          value: /conf/db.sqlite
        ports:
        - containerPort: 80
          name: http
        volumeMounts:
          - name: lychee-photos
            mountPath: /uploads
          - name: lychee-config
            mountPath: /conf
          - name: lychee-sym
            mountPath: /sym
      securityContext:
        fsGroup: 1000
      volumes:
      - name: lychee-photos
        persistentVolumeClaim:
          claimName: lychee-photos
      - name: lychee-config
        persistentVolumeClaim:
          claimName: lychee-config
      - name: lychee-sym
        persistentVolumeClaim:
          claimName: lychee-sym
YAML
}

