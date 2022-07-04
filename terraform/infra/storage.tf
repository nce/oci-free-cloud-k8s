resource "oci_core_volume" "storage" {
  count = var.kubernetes_worker_nodes

  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index].name

  size_in_gbs = "50"
  vpus_per_gb = "10"
}

data "oci_core_instances" "k8s_nodepool" {
  compartment_id = var.compartment_id
}


resource "oci_core_volume_attachment" "storage" {
  count = var.kubernetes_worker_nodes

  display_name = "datenschleuder"
  device       = "/dev/oracleoci/oraclevdh"

  attachment_type                   = "iscsi"
  is_agent_auto_iscsi_login_enabled = "true"
  instance_id                       = data.oci_core_instances.k8s_nodepool.instances[count.index].id
  volume_id                         = oci_core_volume.storage[count.index].id
}
