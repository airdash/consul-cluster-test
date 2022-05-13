resource "helm_release" "nfs_subdir_external_provisioner" {
  repository       = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner"
  chart            = "nfs-subdir-external-provisioner"
  name             = "nfs-subdir-external-provisioner"
  namespace        = "kube-system"
  version          = var.chart_version
  create_namespace = false
  cleanup_on_fail  = true
  
  values = [ file("${path.module}/values.yaml") ]
}
