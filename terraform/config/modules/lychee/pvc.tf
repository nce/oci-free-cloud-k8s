resource "kubectl_manifest" "lychee_pvc_photos" {
  yaml_body = <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lychee-photos
  namespace: lychee
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 25Gi
YAML
}

resource "kubectl_manifest" "lychee_pvc_config" {
  yaml_body = <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lychee-config
  namespace: lychee
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 512Mi
YAML
}

resource "kubectl_manifest" "lychee_pvc_sym" {
  yaml_body = <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: lychee-sym
  namespace: lychee
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 100Mi
YAML
}
