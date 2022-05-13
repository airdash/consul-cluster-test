module "calico_cni" {
  source = "../../modules/calico_cni"
}

module "consul" {
  count = 1
  depends_on = [ module.csi_driver_nfs, module.metallb ]
  source = "../../modules/consul"
}

module "csi_driver_nfs" {
  source = "../../modules/csi_driver_nfs"
}

module "metallb" {
  depends_on = [ module.calico_cni ]
  source = "../../modules/metallb"
}

module "nfs_subdir_external_provisioner" {
  source = "../../modules/nfs_subdir_external_provisioner"
}

module "nginx-consul-identical-name" {
  count = 1
  depends_on = [ module.consul ]
  source = "../../modules/sample_services/nginx-consul-identical-name"
}

module "pihole" {
  count = 1
  depends_on = [ module.consul ]
  domain = "example.com"
  source = "../../modules/pihole"
}

