resource "helm_release" "calico" {
  repository       = "https://projectcalico.docs.tigera.io/charts"
  chart            = "tigera-operator"
  name             = "calico"
  namespace        = var.namespace
  version          = var.chart_version
  create_namespace = true
  cleanup_on_fail  = true
}
