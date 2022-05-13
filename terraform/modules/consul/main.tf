resource "helm_release" "consul" {
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "consul"
  name             = "consul"
  namespace        = var.namespace
  version          = var.chart_version
  create_namespace = true
  cleanup_on_fail  = true

  values = [ file("${path.module}/values.yaml") ]
}

resource "kubernetes_manifest" "ingress_gateway" {
  count = 1

  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "IngressGateway"

    metadata = {
      "name"  = "ingress-gateway-default"
      "namespace" = "default"
    }

    spec = {
      "listeners" = [{
        "port" = "443"
        "protocol" = "http"
        "services" = [{
          "name" = "*"
        }]
      }]
    }
  }
}

