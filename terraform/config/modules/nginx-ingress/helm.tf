resource "helm_release" "nginx_ingress" {
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.12.1"
  namespace  = "nginx-ingress"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 120

  # https://github.com/oracle/oci-cloud-controller-manager/blob/master/docs/load-balancer-annotations.md
  values = [<<YAML
controller:
  config:
    limit-rate: "1048576"
    limit-rate-after: "5242880"
    proxy-buffering: "on"
  replicaCount: 2
  service:
    annotations:
      oci.oraclecloud.com/load-balancer-type: "nlb"
      oci-network-load-balancer.oraclecloud.com/oci-network-security-groups: ${oci_core_network_security_group.ingress_lb.id}
    externalTrafficPolicy: "Local"
    nodePorts:
      https: "30443"
      http: "30080"
YAML
  ]
}


