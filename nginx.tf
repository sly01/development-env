provider "kubernetes" {
}

resource "kubernetes_deployment" "my-nginx" {
  metadata {
    name = "my-nginx"
    labels = {
      app = "my-nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "my-nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-nginx"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "my-nginx"

          port {
            container_port = 80
          }

          volume_mount {
            mount_path = "/usr/share/nginx/html"
            name = "my-nginx-volume"
          }
        }
        volume {
            name = "my-nginx-volume"
            persistent_volume_claim {
              #claim_name = "${kubernetes_persistent_volume_claim.pvc_my-nginx.metadata.0.name}"
              claim_name = "pvc-my-nginx"
            }
          }
      }
    }
  }
}


resource "kubernetes_persistent_volume_claim" "pvc_my-nginx" {
  metadata {
    name = "pvc-my-nginx"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    #volume_name = "${kubernetes_persistent_volume.pv_my-nginx.metadata.0.name}"
  }
}

resource "kubernetes_service" "svc_my-nginx" {
  metadata {
    name = "my-nginx"
  }
  spec {
    selector = {
      app = "my-nginx"
    }
    
    port {
      port        = 8080
      target_port = 80
      node_port   = 32500
    }
    type = "NodePort"
  }
}

# resource "kubernetes_persistent_volume" "pv_my-nginx" {
#   metadata {
#     name = "pv-my-nginx"
#   }
#   spec {
#     capacity = {
#       storage = "5Gi"
#     }
#     persistent_volume_reclaim_policy = "Retain"
#     access_modes = ["ReadWriteOnce"]
#     storage_class
#     persistent_volume_source {
#       host_path  {
#         path  = "/mnt/my-nginx"
#       }
#     }
#   }
# }
