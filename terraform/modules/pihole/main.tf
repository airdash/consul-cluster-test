resource "helm_release" "pihole" {
  repository       = "https://github.com/airdash/pihole-kubernetes.git"
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
  metallb_address_pool = "static-pool"
  namespace = "pihole"
  service_name = "pihole"

  http_listeners = [{
    hostname = format("pihole.%s", var.domain)
    name     = "pihole-http"
    port     = "80"
    protocol = "http"
  }]

  tcp_listeners = [{
    hostname = format("pihole.%s", var.domain)
    name     = "pihole-tcp"
    port     = "53"
    protocol = "tcp"
  }]

  udp_listeners = [{
    hostname = format("pihole.%s", var.domain)
    name     = "pihole-udp"
    port     = "53"
    protocol = "udp"
  }]
}

