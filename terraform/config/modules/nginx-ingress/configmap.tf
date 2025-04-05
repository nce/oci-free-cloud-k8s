resource "kubectl_manifest" "ingress-nginx-ns" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
YAML
}

resource "kubectl_manifest" "teleport-ns" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: teleport
YAML
}

# the securitygroup is needed for the oracle-lb
# in combination with the flux/helmrelease, this gets parsed and annotated on the lb
resource "kubectl_manifest" "ingress-nginx-helm-values" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: oci-lb-sg-id
  namespace: ingress-nginx
data:
  values.yaml: |
    oci:
      lbsecuritygroup: ${oci_core_network_security_group.ingress_lb.id}
YAML
}

resource "kubectl_manifest" "teleport-helm-values" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: oci-nlb-sg-id
  namespace: teleport
data:
  values.yaml: |
    oci:
      nlbsecuritygroup: ${oci_core_network_security_group.ingress_lb.id}
YAML
}
