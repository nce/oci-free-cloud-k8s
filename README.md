# OCI private demo

This repo utilizes the [always free tier](https://blogs.oracle.com/cloud-infrastructure/post/oracle-builds-out-their-portfolio-of-oracle-cloud-infrastructure-always-free-services) of the oracle cloud.

Inital setup is inspired by this great tutorial: https://arnoldgalovics.com/free-kubernetes-oracle-cloud/

## Tooling
- [x] K8s control plane
- [x] Worker Nodes
- [x] Ingress  
  nginx-ingress controller
- [x] Certmanager  
  with letsencrypt
- [x] External DNS  
  with sync to the oci dns management
- [x] Dex as OIDC Provider with github
- [x] ArgoCD
- [ ] Storage
- [x] Grafana

## Renovate
Moving to variables, might not be worth it:
* https://github.com/renovatebot/renovate/discussions/16052

# Setup
#### kubeconfig

```
oci ce cluster create-kubeconfig --cluster-id $(terraform output --raw k8s-cluster-id) --file ~/.kube/oci_cloud.kubeconfig --region eu-frankfurt-1 --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT
```


