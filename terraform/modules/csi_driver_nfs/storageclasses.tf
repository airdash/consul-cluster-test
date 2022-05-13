resource "kubernetes_manifest" "nfs-retain-class" {
  depends_on = [ helm_release.csi_driver_nfs ]
  manifest = {

    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"

    metadata = {
      name = "nfs-csi-retain"
    }
    
    provisioner = "nfs.csi.k8s.io"

    parameters = {
      server = "10.50.0.2"
      share  = "/rpool/kubernetes/nfs-csi-retain"
    }

    reclaimPolicy     = "Retain"
    volumeBindingMode = "Immediate"

    mountOptions = [
      "hard",
      "nfsvers=4.1"
    ]
  }
}

resource "kubernetes_manifest" "nfs-delete-class" {
  depends_on = [ helm_release.csi_driver_nfs ]
  manifest = {

    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"

    metadata = {
      name = "nfs-csi-delete"
    }
    
    provisioner = "nfs.csi.k8s.io"

    parameters = {
      server = "10.50.0.2"
      share  = "/rpool/kubernetes/nfs-csi-delete"
    }

    reclaimPolicy     = "Delete"
    volumeBindingMode = "Immediate"

    mountOptions = [
      "hard",
      "nfsvers=4.1"
    ]
  }
}

