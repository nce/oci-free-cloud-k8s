resource "helm_release" "external_dns" {
  chart      = "external-dns"
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  version    = "1.10.0"
  namespace  = "external-dns"

  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 60

  values = [<<YAML
provider: oci
policy: sync
extraVolumes:
- name: config
  secret:
    secretName: external-dns-config
extraVolumeMounts:
- name: config
  mountPath: /etc/kubernetes/
YAML
  ]

  depends_on = [
    kubectl_manifest.oci_secret
  ]

}
