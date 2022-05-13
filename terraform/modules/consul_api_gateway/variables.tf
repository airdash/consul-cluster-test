variable "domain" {
  type = string
}

variable "hostname" {
  type = string
}

variable "metallb_address_pool" {
  type = string
}

variable "namespace" {
  type = string
  default = "default"
}

variable "service_name" {
  type = string
}

variable "http_listeners" { 
  type = set(object({
    hostname = string
    name = string
    port = string
    protocol = string
  }))
  default = []
}

variable "https_listeners" { 
  type = set(object({
    hostname = string
    name = string
    port = string
    protocol = string
    tls_certificate = string
  }))
  default = []
}

variable "tcp_listeners" { 
  type = set(object({
    hostname = string
    name = string
    port = string
    protocol = string
  }))
  default = []
}

variable "udp_listeners" { 
  type = set(object({
    hostname = string
    name = string
    port = string
    protocol = string
  }))
  default = []
}
