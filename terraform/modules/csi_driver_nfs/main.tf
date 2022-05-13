resource "helm_release" "csi_driver_nfs" {
  repository       = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart            = "csi-driver-nfs"
  name             = "csi-driver-nfs"
  namespace        = "kube-system"
  version          = var.chart_version
  create_namespace = false
  cleanup_on_fail  = true
  
  values = [ file("${path.module}/values.yaml") ]
}
