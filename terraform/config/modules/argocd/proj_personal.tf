resource "kubectl_manifest" "personal_project" {

  depends_on = [
    helm_release.argocd
  ]

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: personal
  namespace: argocd
  # Finalizer that ensures that project is not deleted until it is not referenced by any application
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  # Project description
  description: Personal Project

  # Allow manifests to deploy from any Git repos
  sourceRepos:
  - 'https://github.com/nce/*'

  # Only permit applications to deploy to the guestbook namespace in the same cluster
  destinations:
  - namespace: whoami
    server: https://kubernetes.default.svc

  # Deny all cluster-scoped resources from being created, except for Namespace
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  - group: 'networking.k8s.io'
    kind: Ingress
  - group: ''
    kind: Service

  # Allow all namespaced-scoped resources to be created, except for ResourceQuota, LimitRange, NetworkPolicy
  namespaceResourceBlacklist:
  - group: ''
    kind: ResourceQuota
  - group: ''
    kind: LimitRange
  - group: ''
    kind: NetworkPolicy

  # Enables namespace orphaned resource monitoring.
  orphanedResources:
    warn: false
YAML

}
