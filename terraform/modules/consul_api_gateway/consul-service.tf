resource "kubernetes_manifest" "service_defaults" {
  count = 1

  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "ServiceDefaults"

    metadata = {
      "name"      = format("%s-service-defaults", var.service_name)
      "namespace" = var.namespace
    }

    spec = {
      "protocol" = "http"
    }
  }
}


resource "kubernetes_manifest" "service_resolver" {
  count = 0
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "ServiceResolver"

    metadata = {
      "name"      = "nginx-consul-identical-name"
      "namespace" = "default"
    }

    spec = {
      "defaultSubset" = "v1"
      "subsets" = {
        "v1" = {
          "filter" = "Service.Meta.version == v1"
        }
        "v2" = {
          "filter" = "Service.Meta.version == v2"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "service_router" {
  count = 0

  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "ServiceRouter"

    metadata = {
      "name"      = "nginx-consul-identical-name"
      "namespace" = "default"
    }

    spec = {
      "routes" = [{
        "match" = {
          "http" = {
            "pathPrefix" = "/"
          }
        }
        "destination" = {
          "service" = "nginx-consul-identical-name"
        }
      }]
    }
  }
}

resource "kubernetes_manifest" "service_splitter" {
  count = 0

  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1alpha1"
    "kind"       = "ServiceSplitter"

    metadata = {
      "name"      = "nginx-consul-identical-name"
      "namespace" = "default"
    }

    spec = {
      "splits" = [{
        "weight"        = 100
        "serviceSubset" = "v1"
      }]
    }
  }
}
