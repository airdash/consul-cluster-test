resource "kubernetes_manifest" "gateway" {

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "Gateway"

    metadata = {
      "annotations" = {
        "external-dns.alpha.kubernetes.io/hostname" = "DNS_HOSTNAME"
        "metallb.universe.tf/address-pool" = "external-pool"
      }

      "name"      = "nginx-identical-gateway"
      "namespace" = "default"
    }

    spec = {
      "gatewayClassName" = "nginx-identical-gateway-class"

      "listeners" = [{
        "allowedRoutes" = {
          "namespaces" = {
            "from" = "Same"
          }
        }

        # "hostname" = "DNS_HOSTNAME"
        # "name" = "https"
        # "port" = 443
        # "protocol" = "HTTPS"

        # "tls" = {
        #   "certificateRefs" = {
        #     "name" = "gateway-production-certificate"
        #   }
        # }

        # "hostname" = "DNS_HOSTNAME"

        "hostname" = "nginx-test.example.com"
        "name"     = "http"
        "port"     = 80
        "protocol" = "HTTP"

      }]
    }
  }
}

resource "kubernetes_manifest" "gateway_class_config" {

  manifest = {
    "apiVersion" = "api-gateway.consul.hashicorp.com/v1alpha1"
    "kind"       = "GatewayClassConfig"

    metadata = {
      "name" = "nginx-identical-gateway-class-config"
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
        "service" = [ "external-dns.alpha.kubernetes.io/hostname", "metallb.universe.tf/address-pool" ]
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
      "name" = "nginx-identical-gateway-class"
    }

    spec = {
      "controllerName" = "hashicorp.com/consul-api-gateway-controller"

      "parametersRef" = {
        "group" = "api-gateway.consul.hashicorp.com"
        "kind"  = "GatewayClassConfig"
        "name"  = "nginx-identical-gateway-class-config"
      }
    }
  }
}

resource "kubernetes_manifest" "http_route" {

  manifest = {

    "apiVersion" = "gateway.networking.k8s.io/v1alpha2"
    "kind"       = "HTTPRoute"

    metadata = {
      "name"      = "nginx-identical-route"
      "namespace" = "default"
    }

    spec = {
      "parentRefs" = [{
        "name" = "nginx-identical-gateway"
      }]

      "rules" = [{
        "backendRefs" = [{
          "kind"      = "Service"
          "name"      = "nginx-consul-identical-name"
          "namespace" = "default"
          "port"      = 80
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
      "name"      = "reference-policy"
      "namespace" = "default"
    }

    spec = {
      "from" = [{
        "group"     = "gateway.networking.k8s.io"
        "kind"      = "HTTPRoute"
        "namespace" = "default"
      }]

      "to" = [{
        "group" = ""
        "kind"  = "Service"
        "name"  = "nginx-consul-identical-name"
      }]
    }
  }
}
