resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-deployment"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
        annotations = {
          "consul.hashicorp.com/connect-inject" = "false"
          "consul.hashicorp.com/transparent-proxy" = "false"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "nginx"

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
        service_account_name = "nginx"
      }
    }
  }
}

resource "kubernetes_service" "nginx-loadbalancer" {
  count = 1
  metadata {
    name = "nginx-test-loadbalancer"
    annotations = {
      "metallb.universe.tf/address-pool" = "external-pool"
    }
  }

  spec {
    selector = {
      app = "nginx"
    }

    # session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service" "nginx-clusterip" {
  count = 0
  metadata {
    name = "nginx-test-clusterip"
  }

  spec {
    selector = {
      app = "nginx"
    }

    # session_affinity = "ClientIP"

    port {
      port        = 8080
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service_account" "nginx" {
  metadata {
    name = "nginx"
  }
}

resource "kubernetes_ingress_v1" "nginx" {
  count = 0

  metadata {
    name = "nginx-test"
    annotations = {
      "metallb.universe.tf/address-pool" = "external-pool"
    }
  }

  spec {
    default_backend {
      service {
        name = "nginx-test"
        port { 
          number = 8080
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = "nginx-test"
              port { 
                number = 8080
              }
            }
          }

          path = "/*"
        }
      }
    }
  }
}
