resource "helm_release" "metallb" {
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  name             = "metallb"
  namespace        = "kube-system"
  version          = var.chart_version
  create_namespace = false
  cleanup_on_fail  = true
  
  values = [ file("${path.module}/values.yaml") ]
}

