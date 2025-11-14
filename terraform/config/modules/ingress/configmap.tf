locals {
  namespaces = [
    "envoy-gateway",
    "teleport"
  ]
}
resource "kubectl_manifest" "lb-sg-ns" {
  for_each = toset(local.namespaces)

  lifecycle {
    prevent_destroy = true
  }
  ignore_fields = ["metadata"]

  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: ${each.value}
YAML
}

# Each Loadbalancer created by the OCI Cloud Controller needs to be placed in the
# security group, which allows internet ingress access. Terraform doesn't create
# the LB, so we need to store the information in the cluster.
# In combination with the flux/helmrelease, this gets evaluated and annotated on the lb
resource "kubectl_manifest" "lg-sg-helm-values" {
  for_each = toset(local.namespaces)

  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: oci-lb-sg-id
  namespace: ${each.value}
data:
  values.yaml: |
    oci:
      lbsecuritygroup: ${oci_core_network_security_group.ingress_lb.id}
YAML
}
