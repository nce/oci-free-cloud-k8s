provider "github" {
  owner = var.gh_org
  token = var.gh_token
}

resource "helm_release" "flux_operator" {
  depends_on = [kubernetes_namespace.flux_system]

  name       = "flux-operator"
  namespace  = kubernetes_namespace.flux_system.id
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-operator"
  wait       = true
}

resource "kubernetes_secret" "git_auth" {
  depends_on = [kubernetes_namespace.flux_system]

  metadata {
    name      = "flux-instance-config"
    namespace = kubernetes_namespace.flux_system.id
  }

  data = {
    username                = null
    password                = null
    githubAppID             = "${var.github_app_id}"
    githubAppInstallationID = "${var.github_app_installation_id}"
    githubAppPrivateKey     = "${var.github_app_pem}"
  }

  type = "Opaque"
}

// Configure the Flux instance.
resource "helm_release" "flux_instance" {
  depends_on = [helm_release.flux_operator]

  name       = "flux"
  namespace  = kubernetes_namespace.flux_system.id
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"

  values = [<<YAML
instance:
  distribution:
    version: ${var.flux_version}
    registry: ${var.flux_registry}
  sync:
    kind: GitRepository
    url: ${var.git_url}
    path: gitops/core
    ref: "refs/heads/main"
    provider: github
    pullSecret: flux-instance-config
YAML
  ]
}
