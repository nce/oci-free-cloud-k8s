resource "kubectl_manifest" "nginx-ingress-ns" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
YAML
}

# the securitygroup is needed for the oracle-nlb
# in combination with the flux/helmrelease, this gets parsed and annotated on the lb
resource "kubectl_manifest" "ingress-helm-values" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: oci-nlb-sg-id
  namespace: ingress-nginx
data:
  values.yaml: |
    oci:
      nlbsecuritygroup: ${oci_core_network_security_group.ingress_lb.id}
YAML
}
