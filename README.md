# OCI private demo

This repo utilizes the [always free tier](https://blogs.oracle.com/cloud-infrastructure/post/oracle-builds-out-their-portfolio-of-oracle-cloud-infrastructure-always-free-services) of the oracle cloud.

Inital setup is inspired by this great tutorial: https://arnoldgalovics.com/free-kubernetes-oracle-cloud/

#### kubeconfig

```
oci ce cluster create-kubeconfig --cluster-id $(terraform output --raw k8s-cluster-id) --file ~/.kube/oci_cloud.kubeconfig --region eu-frankfurt-1 --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT
```

## Projectstatus
- [x] K8s control plane
- [x] Worker Nodes
- [ ] Ingress
- [ ] ArgoCD
- [ ] Certmanager
