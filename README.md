# :cloud: Oracle Cloud free tier setup

This repo utilizes the [always free tier](https://blogs.oracle.com/cloud-infrastructure/post/oracle-builds-out-their-portfolio-of-oracle-cloud-infrastructure-always-free-services) of the oracle cloud.
In its current state, i just pay a few cents for dns management.

In the orcale cloud the Kubernetes controlplane (oke) is free for use, you just pay for the workers, if you surpass the always free tier.
The 4 oCpus and 24GB memory are divided by two instances, leading to a good resource utilization.
The boot partions are 100Gb each, allowing `longhorn` to use 

The initial infra setup is inspired by this great tutorial: https://arnoldgalovics.com/free-kubernetes-oracle-cloud/

## :wrench: Tooling
- [x] K8s control plane
- [x] Worker Nodes
- [x] Ingress  
  nginx-ingress controller
- [x] Certmanager  
  with letsencrypt
- [x] External DNS  
  with sync to the oci dns management
- [x] Dex as OIDC Provider with github
- [x] ArgoCD with Dex Login
- [x] Storage  
  with longhorn (rook/ceph & piraeus didnt work out)
- [x] Grafana with Dex Login
- [ ] Kyverno and Image Signing

## Renovate
This repo uses renovate to update all terraform providers and helm charts.

The helm chart versions need to be stored alongside the repository info, and
not in tf variables. Using variables might be possible, but quite ugly.
* https://github.com/renovatebot/renovate/discussions/16052

# Setup
#### kubeconfig

```
oci ce cluster create-kubeconfig --cluster-id $(terraform output --raw k8s-cluster-id) --file ~/.kube/oci_cloud.kubeconfig --region eu-frankfurt-1 --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT
```

# Issues
* Grafana has no oci-datasource because the oci plugin is [not build for arm64](https://github.com/oracle/oci-grafana-metrics/issues/110)
