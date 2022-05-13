provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kubernetes-calico" 
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kubernetes-calico" 
  }
}


