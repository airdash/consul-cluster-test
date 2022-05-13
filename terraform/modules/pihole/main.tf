resource "helm_release" "pihole" {
  repository       = "https://mojo2600.github.io/pihole-kubernetes/"
  chart            = "pihole"
  name             = "pihole"
  namespace        = "pihole"
  version          = var.chart_version
  create_namespace = true
  cleanup_on_fail  = true
  values           = [ file("${path.module}/values.yaml") ]
}

module "consul_api_gateway" {
  depends_on = [ helm_release.pihole ]
  source = "../consul_api_gateway"

  domain   = var.domain
  hostname = format("pihole.%s", var.domain)
  metallb_address_pool = "external-pool"
  namespace = "pihole"
  service_name = "pihole"

  http_listeners = [{
    hostname = format("pihole.%s", var.domain)
    port     = "80"
  }]

  tcp_listeners = [{
    hostname = format("pihole.%s", var.domain)
    port     = "53"
  }]
}
