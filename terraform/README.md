# Structure
I decided to split the terraform provisioning in two parts.

* [cluster-infra](infra/) for everything leading to a functioning k8s API, including OCI Vault and External Secrets IAM
* [cluster-config](config/) for everything depending on a k8s API

This way i mitigate long terraform runs and provider dependency.

The infra module outputs several values needed by the config module, including vault credentials for External Secrets operator.
