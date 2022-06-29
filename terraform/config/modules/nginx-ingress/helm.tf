resource "helm_release" "nginx_ingress" {
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = var.chart_version
  namespace  = "nginx-ingress"

  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true
  timeout          = 120

  values = [<<YAML
controller:
  service:
    annotations:
      service.beta.kubernetes.io/oci-load-balancer-shape: flexible
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-min: 10
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-max: 10
      oci.oraclecloud.com/oci-network-security-groups: ${oci_core_network_security_group.ingress_lb.id}
YAML
  ]
}


