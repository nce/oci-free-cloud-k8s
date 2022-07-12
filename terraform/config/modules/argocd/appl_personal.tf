resource "kubectl_manifest" "personal_application_whoami" {

  depends_on = [
    helm_release.argocd
  ]

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: whoami
  namespace: argocd
spec:
  project: personal
  source:
    repoURL: https://github.com/nce/whoami.git
    targetRevision: HEAD
    path: k8s/prod/
  destination:
    server: https://kubernetes.default.svc
    namespace: whoami
  syncPolicy:
    automated:
      prune: true
YAML
}
