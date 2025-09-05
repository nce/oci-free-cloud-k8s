# ⎈ Oracle Cloud Kubernetes free tier setup

This repository leverages Oracle Cloud's [always free tier][oci-free-tier] to provision a kubernetes cluster.
In its current setup there are **no monthly costs** anymore, as I've now moved
the last part (DNS) from oci to cloudflare.

[oci-free-tier]: https://blogs.oracle.com/cloud-infrastructure/post/oracle-builds-out-their-portfolio-of-oracle-cloud-infrastructure-always-free-services

Oracle Kubernetes Engine (OKE) is free to use, and you only pay for worker
nodes _if_ you exceed the Always Free tier — which we don’t.
The free tier provides **4 oCPUs and 24GB of memory**, which are split between two
worker nodes (`VM.Standard.A1.Flex`), allowing for efficient resource
utilization. Each node has a 100GB boot volume, with around 60GB available for
in-cluster storage via Longhorn. For ingress, we use `k8s.io/nginx` with Oracle’s
Flexible Load Balancer (10Mbps; layer 7), for `teleport` we use the network LB (layer 4),
as both are free as well.

Getting an Always Free account can sometimes be tricky, but there are several
guides on Reddit that explain how to speed up the creation process.

The initial infra setup is inspired by this great tutorial: https://arnoldgalovics.com/free-kubernetes-oracle-cloud/

> [!WARNING]
> This project uses arm instances, no x86 architecture; due to limitations
> of the always free tier.
>
> *And please mind:*
> This setup is loosely documented and opinionated. It's working and in use
> by myself. It's public, to showcase how this setup can be recreated, but
> you need to know what you're doing and where to make modification for yourself.

This repo hosts my personal stuff and is a playground for my kubernetes tooling.

> [!TIP]
> In case you want to reproduce another `oke` setup, you might [find this guide](https://github.com/piontec/free-oci-kubernetes)
> also helpful.

## :wrench: Tooling

- [x] K8s control plane
- [x] Worker Nodes
- [x] Ingress
  * nginx-ingress controller on a layer 7 lb
  * teleport svc on a layer 4 lb
- [x] Certmanager
  * with letsencrypt for dns & http challenge
- [x] External DNS
  * with sync to the cloudflare dns management
  * CR to provide `A` records for my home-network
- [x] Dex as OIDC Provider
  * with github as idP
- [x] FluxCD for Gitops
  * deployed with the new fluxcd operator
  * github → flux webhook receiver for instant reconciliation
  * flux → github commit annotation about conciliation status
- [x] Teleport for k8s cluster access
- [x] Storage
   * with longhorn (rook/ceph & piraeus didn't work out)
- [x] Grafana with Dex Login
   * Dashboards for Flux
   * [ ] Switch to Grafana Operator
- [ ] Loki for log aggregation
- [x] Metrics Server for cpu/mem usage overview
- [ ] Kyverno and Image Signing
- [x] [S3 Proxy](https://github.com/oxyno-zeta/s3-proxy) for http access of buckets

# :keyboard: Setup
> [!Note]
> I've recently updated the tf-backend config,  to utilizes the oci native
> backend now. This requires terraform >= v1.12

This setup uses terraform to manage the oci **and** a bit of the kubernetes part.

## Tooling on the client side

* terraform
* oci-binary
* `oci setup config` successfully run

The terraform state is pushed to oracle object storage (free as well). For that
we have to create a bucket initially:
```
❯ oci os bucket create --name terraform-states --versioning Enabled --compartment-id xxx
```

With the bucket created we can configure the `~/.oci/config`:
```
[DEFAULT]
user=ocid1.user.xxx
fingerprint=ee:f4:xxx
tenancy=ocid1.tenancy.oc1.xxx
region=eu-frankfurt-1
key_file=/Users/xxxx.pem

[default]
aws_access_key_id = xxx <- this needs to be created via UI: User -> customer secret key
aws_secret_access_key = xxx <- this needs to be created via UI: User -> customer secret key

```
Refer to my [backend config](./terraform/infra/_terraform.tf) for the terraform s3 configuration.

## 🏗️ Terraform Layout
* The infrastructure (everything to a usable k8s-api endpoint) is managed by
terrafom in [infra](terraform/infra/)
* The k8s-modules (OCI specific config for secrets etc.) are managed by terraform in [config](terraform/config/)
* The k8s apps/config is done with flux; see below

These components are independent from each other, but obv. the infra should
be created first.

For the config part, you need to add a private `*.tfvars` file:
```
compartment_id   = "ocid1.tenancy.zzz"
... # this list is currently not complete; there's more to add
```

Running the `config` section you need more variables, which either get output
by the `infra`-run or have to be extracted from the webui.

> [!TIP]
> During the initial provisioning the terraform run of `config` might fail,
> it's trying to create a `ClusterSecretStore` which only exist after the
> initial deployment of `external secrets` with flux. This is expected.
> Just rerun terraform after external secrets is successfully deployed.

## Kubernets Access - kubeconfig
After running terraform in the [infra](./terraform/infra) folder, a kubeconfig file
should be created in the terraform folder called `.kube.config`.
This can be used to access the cluster.
For a more regulated access, see the Teleport section below.

The terraform resources in the [config](./terraform/config) folder will rely on the kubeconfig.

## FluxCD
Most resources and core components of the k8s cluster are provisioned with fluxcd.
Therefore we need a Github Personal acccess Token (`pat` - fine grained) in your repo.
```
# github permission scope for the token:
contents - read, write
commit statuses - read, write
webhooks - read, write
```

* Place this token in a private tfvars. This is used to
generate the fluxcd webhook url, which triggers fluxcd reconciliation after each
commit
* Place this token in the oci vault (`github-fluxcd-token`). This allows fluxcd
to annotate the github commit status, depending on the state of the `Kustomization`.

### Fluxcd Operator
Migrating from the `flux bootstrap` method to the flux-operator might be tricky.
I lost most installed apps during my upgrade, because i misconfigured the
`FluxInstace.path` (this could've mitigated by setting `prune: false` on the KS).
Destroying the old Bootstrap resource during the TF apply, lead
to the removal of the fluxcd crds like `GitRepo, HelmRelease` etc
(had the remove the finalizers of the crds
to allow removal). This didn't impact my already deployed CRs though.
The Flux Operator takes care of reinstalling everything.

I've setup a Githup App and mostly followed the official guide,
this was pretty straightforward.

#### Development
Switching to a feature/dev branch is rather simple, just modify the
inCluster `FluxInstance` - search for the `sync` block and update the `ref`
section to the according branch.

## Teleport
[Teleport](https://goteleport.com/) is my preferred way to access the kuberentes api
### Prerequisites
In it's current state, teleport wants to setup a wildcard domain like `*.teleport.example.com` (could be disabled).
With OracleCloud managing the dns, this is not possible, as `cert-manager` is not
able to do a `dns01` challenge against orcale dns.
I've now switched to Cloudflare (also to mitigate costs of a few cents).

The Teleport <-> K8s Role (`k8s/system:masters`) is created by the teleport
operator (see the `fluxcd-addons/Kustomization`). The SSO setup is created with
[fluxcd](./gitops/core/teleport/rbac).

### ~Login via local User~ - removed
I've removed local users in teleport and am using SSO with github as idP.

This might still be useful for local setups not using SSO:

The login process must be `reset` for each user, so that
password and 2FA can be configured by each user in the WebUI.
The User can be created via the teleport-operator by creating a `TelepertUser` in
kubernetes.
```
# reset the user once
❯ k --kubeconfig ~/.kube/oci.kubeconfig exec -n teleport -ti deployment/teleport-cluster-auth -- tctl users reset nce

# login to teleport
❯ tsh login --proxy teleport.nce.wtf:443 --auth=local --user nce teleport.nce.wt
```

### Login via Github
There's no user management in teleport, so no reset, or 2FA setup is needed.
```
❯ tsh login --proxy teleport.nce.wtf:443 --auth=github-acme --user nce teleport.nce.wtf

# login to the k8s cluster
❯ tsh kube login oci

# test
❯ k get po -n teleport
```

### Certificates
The x509 certs are managed by `cert-manager`. With the dns management done by
cloudflare, i've removed all `http01` challenges. The renewal process with
`http01` and cloudflare is [out of the box not possible][cert-manager-cloudflare]

Switching to `dns` challenge solves this issue.

### LB setup

> [!WARNING]
> Todo: write about the svc/ingress annotations of the security groups

## Monitoring

# :money_with_wings: Cost
Overview of my monthly costs:
![](docs/cost.aug.oct.22.png)

# :books: Docs
A collection of relevant upstream documentation for reference

## Ingress
* LB Annotation [for oracle cloud][lb-annotations]
* Providing OCI-IDs to Helm Releases on [nginx][nginx-helm-lb-annotations]

## Cert Manager
* [DNS01 Challenge][cert-manager-dns-challenge]

## External Secrets
* [Advanced Templating for secrets][secrets-templating]

## External Dns
* [CRDs for DNS records][dns-crds]

## Teleport
* [teleport-operator][teleport-operator]
* Teleport [User/Roles RBAC][teleport-rbac]
* Mapping to teleport role
* [SSO with GithubConnector][teleport-github-sso] and [External Client Secret][teleport-client-secret]
* [Helm Chart Deploy Infos][teleport-helm-doc] & [Helm Chart ref][teleport-helm-chart]

## FluxCD
* [Monitoring setup][flux-monitoring]
* [Webhook Config][flux-webhook]
* [Webhook Url Hashing][flux-webhook-hashing]
* [FluxCD Operator][flux-operator-migration]

[lb-annotations]: https://github.com/oracle/oci-cloud-controller-manager/blob/master/docs/load-balancer-annotations.md
[nginx-helm-lb-annotations]: https://github.com/kubernetes/ingress-nginx/blob/74ce7b057e8d4ac96d2e11e027930397e5f70010/charts/ingress-nginx/templates/controller-service.yaml#L7
[cert-manager-dns-challenge]: https://cert-manager.io/docs/configuration/acme/dns01/
[cert-manager-cloudflare]: https://ryanschiang.com/cloudflare-letsencrypt-http-01

[secrets-templating]: https://external-secrets.io/v0.15.0/guides/templating/#helm

[dns-crds]: https://kubernetes-sigs.github.io/external-dns/latest/docs/sources/crd/#using-crd-source-to-manage-dns-records-in-different-dns-providers

[teleport-client-secret]: https://goteleport.com/docs/admin-guides/infrastructure-as-code/teleport-operator/secret-lookup/#step-23-create-a-custom-resource-referencing-the-secret
[teleport-github-sso]: https://goteleport.com/docs/admin-guides/access-controls/sso/github-sso/
[teleport-rbac]: https://goteleport.com/docs/admin-guides/access-controls/getting-started/#step-13-add-local-users-with-preset-roles
[teleport-helm-chart]: https://goteleport.com/docs/reference/helm-reference/teleport-cluster/
[teleport-helm-doc]: https://goteleport.com/docs/admin-guides/deploy-a-cluster/helm-deployments/kubernetes-cluster/
[teleport-operator]: https://goteleport.com/docs/admin-guides/infrastructure-as-code/teleport-operator/

[flux-monitoring]: https://fluxcd.io/flux/monitoring/metrics/#monitoring-setup
[flux-webhook]: https://fluxcd.io/flux/guides/webhook-receivers/
[flux-webhook-hashing]: https://github.com/fluxcd/notification-controller/issues/1067
[flux-operator-migration]: https://fluxcd.control-plane.io/operator/flux-bootstrap-migration/

# Upgrading the Kubernetes Version
I recommend only upgrading to the version the first command (`available-kubernetes-upgrades`) shows.
Other upgrades, or jumps to the latest version not being shown, might break the process.
The [K8s Skew policy][k8s-skew] allows the worker nodes (`kubelets`)
to be three minor versions behind, so you might be alright, if you incrementally update the controlplane,
before updating the nodepool.

[k8s-skew]: https://kubernetes.io/releases/version-skew-policy/#kubelet

The commands should be executed inside [terraform/infra/](terraform/infra)
```
# get new cluster versions
❯ oci ce cluster get --cluster-id $(terraform output --raw k8s_cluster_id) | jq -r '.data."available-kubernetes-upgrades"'

# update the cluster version with the information from above
❯ sed -i '' 's/default = "'$(terraform output --raw kubernetes_version)'"/default = "v1.31.1"/' _variables.tf

# upgrade the controlplane and the nodepool & images
# this shouldn't roll the nodes and might take around 10mins
❯ terraform apply
```
 To roll the nodes, i cordon & drain the k8s node:
```
❯ k drain <k8s-node-name> --force --ignore-daemonsets --delete-emptydir-data
❯ k cordon <k8s-node-name>
```
A node deletion in k8s doesn't trigger a change in the `nodepool`. For that, we
need to terminate the correct instance. But i haven't figured out how to delete the -
currently cordoned - node, only using `oci`.

So, login to the webui -> Oke Cluster -> Node pool and check for the right
instance by looking at the private_ip and copy the id.

Now terminate that instance:
```
❯ oci compute instance terminate --force --instance-id <oidc.id>
```
This triggers a node recreation. Now wait till the node is Ready; And then wait for
longhorn to sync the volumes.
```
# wait until all volumes are healthy again
❯ k get -w volumes.longhorn.io -A
```
Repeat the cordon/drain/terminate for the second node.
### OKE Upgrade 1.31.1
For the current update, i've written above upgrade instructions.
Worked flawlessly, though still with a bit of manual interaction in the webui...

### OKE Upgrade 1.29.1
I mostly skipped `1.27.2` & `1.28.2` (on the workers) and went for the `1.29` release. As the UI didn't
prompt for a direct upgrade path of the control-plane, i upgraded the k8s-tf
version to the prompted next release, ran the upgrade, and continued with the next version.

The worker nodes remained at `1.26.7` during the oke upgrade, which worked because with 1.28
the new skew policy allows for worker nodes to be three versions behind.

### OKE Upgrade 1.25.4

:warning: remember to remove any `PSP`s first

1. Upgrade the nodepool & cluster version by setting the k8s variable; Run terrafrom (takes ~10min)
2. Drain/Cordon worker01
3. Go to the UI; delete the worker01 from the nodepool
4. Scale the Nodepool back to 2 (takes ~10min)
5. Wait for longhorn to sync (no volume in state `degraded`)
6. repeat for second node (2-5)

### OKE Upgrade 1.24

The 1.23.4 -> 1.24.1 Kubernetes Upgrade went pretty smooth, but by hand.

I followed the official guide:

- https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengupgradingk8smasternode.htm
- https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengupgradingk8sworkernode.htm

Longhorn synced all volumes after the new node got ready. No downtime experienced.
