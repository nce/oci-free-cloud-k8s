data "oci_secrets_secretbundle" "ghcr_image_pullsecret" {
  secret_id = "ocid1.vaultsecret.oc1.eu-frankfurt-1.amaaaaaasuzlxsiadwphbmnzmr7xst4hqqcxyvd2d52hanjttv7m6ys7fkdq"
}

resource "kubernetes_secret" "ghcr_imgage_pull" {

  metadata {
    name = "ghcr"
    namespace = "whoami"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" : {
        "https://ghcr.io" : {
          username = "nce"
          password = trimspace(base64decode(data.oci_secrets_secretbundle.ghcr_image_pullsecret.secret_bundle_content.0.content))
          auth     = base64encode(join(":", ["nce", base64decode(data.oci_secrets_secretbundle.ghcr_image_pullsecret.secret_bundle_content.0.content)]))
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

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
