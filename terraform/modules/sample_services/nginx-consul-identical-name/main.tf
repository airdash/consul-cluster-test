resource "kubernetes_deployment" "nginx_deployment" {
  count = 1

  depends_on = [kubernetes_service.nginx_service, kubernetes_service_account.nginx_service_account]

  metadata {
    name = "nginx-consul-identical-name"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = "nginx-consul-identical-name"
        version = "v1"
      }
    }

    template {
      metadata {
        labels = {
          app     = "nginx-consul-identical-name"
          version = "v1"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject"                     = "true"
          "consul.hashicorp.com/transparent-proxy"                  = "true"
          "consul.hashicorp.com/transparent-proxy-overwrite-probes" = "true"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "nginx-consul-identical-name"

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }

          port {
            container_port = 80
            name           = "http"
          }
        }
        service_account_name = "nginx-consul-identical-name"
      }
    }
  }
}

resource "kubernetes_service" "nginx_service" {

  metadata {
    name = "nginx-consul-identical-name"
    annotations = {
      "consul.hashicorp.com/service-name" = "nginx-consul-identical-name"
      "consul.hashicorp.com/service-tags" = "v1"
    }
  }

  spec {
    selector = {
      app     = "nginx-consul-identical-name"
      version = "v1"
    }

    # session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 80
    }
    # type = "LoadBalancer"
  }
}

resource "kubernetes_service_account" "nginx_service_account" {
  metadata {
    name = "nginx-consul-identical-name"
  }
}

