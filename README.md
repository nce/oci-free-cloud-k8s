# :cloud: Oracle Cloud kubernetes free tier setup

This repo utilizes the [always free tier](https://blogs.oracle.com/cloud-infrastructure/post/oracle-builds-out-their-portfolio-of-oracle-cloud-infrastructure-always-free-services) of the oracle cloud to provision a kubernetes cluster.
In its current state, i just pay a few cents for dns management.

At orcale cloud the Kubernetes controlplane (oke) is free to use, you just pay
for the workers, *if* you surpass the always free tier (which we don't).
You get 4 oCpus and 24GB memory which are split into two worker-instances
(`VM.Standard.A1.Flex` -> arm), allowing good resource utilization.
The boot partions are 100Gb each, allowing `longhorn` to use around 60GB as in
cluster storage. For the ingress class we use `nginx` with the oracle Flexible 
LB (10Mbps), because that's free as well.

The initial infra setup is inspired by this great tutorial: https://arnoldgalovics.com/free-kubernetes-oracle-cloud/

> :warning: This project uses arm instances, no x86 architecture

This repo hosts my personal stuff and is a playground for my kubernetes tooling

## :wrench: Tooling
- [x] K8s control plane
- [x] Worker Nodes
- [x] Ingress  
  nginx-ingress controller
- [x] Certmanager  
  with letsencrypt
- [x] External DNS  
  with sync to the oci dns management
- [x] Dex as OIDC Provider with github as idP
- [x] ArgoCD with Dex Login
- [x] Storage  
  with longhorn (rook/ceph & piraeus didnt work out)
- [x] Grafana with Dex Login
- [ ] [kube-Prometheus/Alertmanager-stack](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/README.md)
- [ ] [Prometheus Metrics Adapter](https://github.com/kubernetes-sigs/prometheus-adapter)
- [ ] Kyverno and Image Signing

## :keyboard: Setup

This setup uses terraform to managed the oci and kubernetes part.

The terraform state is pushed to the oracle object storage (free as well). For that
we have to create a bucket initially:
```
$ oci os bucket create --name terraform-states --versioning Enabled --compartment-id xxx
```

* The infrastructure (everything to a usable k8s-api endpoint) is managed by
terrafom in [infra](infra/)
* The k8s-modules (usually helm) are managed by terraform in [config](config/)

These components are independed from eachother, but obv. the infra should
be created first.

For the config part, we need to add a private `*.tfvars` file:
```
node_pool_id     = "ocid1.nodepool.xxx"
public_subnet_id = "ocid1.subnet.yyy"
compartment_id   = "ocid1.tenancy.zzz"
vault_id         = "ocid1.vault.aaa"
```

* The first & second value are outputs from the infra-terraform.
* The third & fourth value are currently extracted from the webui

### kubeconfig
With the following command we get the kubeconfig for terraform/direct access:
```
# in the infra folder
oci ce cluster create-kubeconfig --cluster-id $(terraform output --raw k8s_cluster_id) --file ~/.kube/configs/oci.kubeconfig --region eu-frankfurt-1 --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT
```

# Cost
![](docs/cost.aug.oct.22.png)

## :telescope: renovate maintenance 
This repo utilizes renovate to update all terraform providers and helm charts.

The helm chart versions need to be stored alongside the repository info, and
not in tf variables. Using variables might be possible, but quite ugly.
* https://github.com/renovatebot/renovate/discussions/16052

# Issues
* Grafana has no oci-datasource because the oci plugin is [not build for arm64](https://github.com/oracle/oci-grafana-metrics/issues/110)  
  This seems to be fixed, but i've still some issues accessing the datasource,
  could be iam...

## Upgrade
### OKE Upgrade 1.25.4
1. Upgrade the nodepool & cluster version by setting the k8s variable; Run terrafrom (takes ~10min)
2. Drain/Cordon worker01
3. Go to the UI; delete the worker01 from the nodepool
4. Scale the Nodepool back to 2 (takes ~10min)
5. Wait for longhorn to sync (no volume in state `degraded`)
6. repeat for second node (2-5)

### OKE Upgrade 1.24
The 1.23.4 -> 1.24.1 Kubernetes Upgrade went pretty smooth, but by hand.

I followed the official guide:
* https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengupgradingk8smasternode.htm
* https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengupgradingk8sworkernode.htm

Longhorn synced all volumes after the new node got ready. No downtime experienced.
