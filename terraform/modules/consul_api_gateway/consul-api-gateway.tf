locals {

  http_listeners = [ for listener in var.http_listeners : {
    "hostname" = listener.hostname
    "name"     = format("%s-%s-%s", var.service_name, "http", listener.port)
    "port"     = listener.port
    "protocol" = "http"
  }]

  https_listeners = [ for listener in var.https_listeners : {
    "tls" = {
      "certificateRefs" = {
        "name" = listener.tls_certificate
      }
    }

    "hostname" = listener.hostname
    "name"     = format("%s-%s-%s", var.service_name, "https", listener.port)
    "port"     = listener.port
    "protocol" = "http"
  }]

  tcp_listeners = [ for listener in var.tcp_listeners : {
    "name"     = format("%s-%s-%s", var.service_name, "tcp", listener.port)
    "port"     = listener.port
    "protocol" = "tcp"
  }]

  udp_listeners = [ for listener in var.udp_listeners : {
    "name"     = format("%s-%s-%s", var.service_name, "udp", listener.port)
    "port"     = listener.port
    "protocol" = "udp"
  }]

  http_gateway_enabled  = length(var.http_listeners) > 0 ? 1 : 0
  https_gateway_enabled = length(var.https_listeners) > 0 ? 1 : 0
  tcp_gateway_enabled   = length(var.tcp_listeners) > 0 ? 1 : 0
  udp_gateway_enabled   = length(var.udp_listeners) > 0 ? 1 : 0
}

resource "kubernetes_manifest" "http_gateway" {
  count = local.http_gateway_enabled
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "Gateway"

    "metadata" = {
      "annotations" = {
        "external-dns.alpha.kubernetes.io/hostname" = var.hostname
        "metallb.universe.tf/address-pool" = var.metallb_address_pool
        "metallb.universe.tf/allow-shared-ip" = var.service_name
      }

      "name"      = format("%s-%s", var.service_name, "http-gateway")
      "namespace" = var.namespace
    }

    "spec" = {
      "gatewayClassName" = format("%s-gateway-class", var.service_name)
      "listeners" = local.http_listeners
    }
  }
}

resource "kubernetes_manifest" "https_gateway" {
  count = local.https_gateway_enabled
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "Gateway"

    "metadata" = {
      "annotations" = {
        "external-dns.alpha.kubernetes.io/hostname" = var.hostname
        "metallb.universe.tf/address-pool" = var.metallb_address_pool
        "metallb.universe.tf/allow-shared-ip" = var.service_name
      }

      "name"      = format("%s-%s", var.service_name, "https-gateway")
      "namespace" = var.namespace
    }

    "spec" = {
      "gatewayClassName" = format("%s-gateway-class", var.service_name)
      "listeners" = local.https_listeners 
    }
  }
}

resource "kubernetes_manifest" "tcp_gateway" {
  count = local.tcp_gateway_enabled
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "Gateway"

    "metadata" = {
      "annotations" = {
        "external-dns.alpha.kubernetes.io/hostname" = var.hostname
        "metallb.universe.tf/address-pool" = var.metallb_address_pool
        "metallb.universe.tf/allow-shared-ip" = var.service_name
      }

      "name"      = format("%s-%s", var.service_name, "tcp-gateway")
      "namespace" = var.namespace
    }

    "spec" = {
      "gatewayClassName" = format("%s-gateway-class", var.service_name)
      "listeners" = local.tcp_listeners
    }
  }
}

resource "kubernetes_manifest" "udp_gateway" {
  count = local.udp_gateway_enabled
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "Gateway"

    "metadata" = {
      "annotations" = {
        "external-dns.alpha.kubernetes.io/hostname" = var.hostname
        "metallb.universe.tf/address-pool" = var.metallb_address_pool
        "metallb.universe.tf/allow-shared-ip" = var.service_name
      }

      "name"      = format("%s-%s", var.service_name, "udp-gateway")
      "namespace" = var.namespace
    }

    "spec" = {
      "gatewayClassName" = format("%s-gateway-class", var.service_name)
      "listeners" = local.udp_listeners
    }
  }
}

resource "kubernetes_manifest" "gateway_class_config" {

  manifest = {
    "apiVersion" = "api-gateway.consul.hashicorp.com/v1alpha1"
    "kind"       = "GatewayClassConfig"

    metadata = {
      "name" = format("%s-gateway-class-config", var.service_name)
    }

    spec = {
      "consul" = {
        "ports" = {
          "grpc" = 8502
          "http" = 8501
        }

        "scheme" = "https"
      }

      "copyAnnotations" = {
        "service" = [ "external-dns.alpha.kubernetes.io/hostname", "metallb.universe.tf/address-pool", "metallb.universe.tf/allow-shared-ip" ]
      }

      "logLevel"     = "info"
      "serviceType"  = "LoadBalancer"
      "useHostPorts" = false
    }
  }
}

resource "kubernetes_manifest" "gateway_class" {

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "GatewayClass"

    metadata = {
      "name" = format("%s-gateway-class", var.service_name)
    }

    spec = {
      "controllerName" = "hashicorp.com/consul-api-gateway-controller"

      "parametersRef" = {
        "group" = "api-gateway.consul.hashicorp.com"
        "kind"  = "GatewayClassConfig"
        "name"  = format("%s-gateway-class-config", var.service_name)
      }
    }
  }
}

resource "kubernetes_manifest" "http_route" {
  count = local.http_gateway_enabled

  manifest = {

    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "HTTPRoute"

    metadata = {
      "name"      = format("%s-http-route", var.service_name)
      "namespace" = var.namespace
    }

    spec = {
      "parentRefs" = [{
        "name"      = format("%s-%s", var.service_name, "http-gateway")
      }]

      "rules" = [{
        "backendRefs" = [ for listener in local.http_listeners : {
          "kind"      = "Service"
          "name"      = format("%s-%s-%s", var.service_name, "http", listener.port)
          "namespace" = var.namespace
          "port"      = listener.port
        }]
      }]
    }
  }
}

resource "kubernetes_manifest" "https_route" {
  count = local.https_gateway_enabled

  manifest = {

    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "HTTPRoute"

    metadata = {
      "name"      = format("%s-http-route", var.service_name)
      "namespace" = var.namespace
    }

    spec = {
      "parentRefs" = [{
        "name"      = format("%s-%s", var.service_name, "https-gateway")
      }]

      "rules" = [{
        "backendRefs" = [ for listener in local.https_listeners : {
          "kind"      = "Service"
          "name"      = format("%s-%s-%s", var.service_name, "https", listener.port)
          "namespace" = var.namespace
          "port"      = listener.port
        }]
      }]
    }
  }
}

resource "kubernetes_manifest" "reference_policy" {

  manifest = {

    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "ReferencePolicy"

    metadata = {
      "name"      = format("%s-reference-policy", var.service_name)
      "namespace" = var.namespace
    }

    spec = {
      "from" = [{
        "group"     = "gateway.networking.k8s.io"
        "kind"      = "HTTPRoute"
        "namespace" = var.namespace
      }]

      "to" = [{
        "group" = ""
        "kind"  = "Service"
        "name"  = var.service_name
      }]
    }
  }
}
