provider "kubernetes" {
  
}

resource "kubernetes_namespace" "ns_development" {
  metadata {
    name = "development"
  }
}

resource "kubernetes_deployment" "gogs-postgres" {
  metadata {
    name = "gogs-postgres"
    labels = {
      app = "gogs-postgres"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gogs-postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "gogs-postgres"
        }
      }

      spec {
        container {
          image = "postgres:9.5"
          name  = "gogs-postgres"

          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_USER"
            value = "gogs"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = "123456"
          }
          env {
            name = "POSTGRES_DB"
            value = "gogs"
          }
          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name = "gogs-postgres-volume"
          }
        }
        volume {
            name = "gogs-postgres-volume"
            persistent_volume_claim {
              #claim_name = "${kubernetes_persistent_volume_claim.pvc_gogs-postgres.metadata.0.name}"
              claim_name = "pvc-gogs-postgres"
            }
          }
      }
    }
  }
}


resource "kubernetes_persistent_volume_claim" "pvc_gogs-postgres" {
  metadata {
    name = "pvc-gogs-postgres"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    #volume_name = "${kubernetes_persistent_volume.pv_gogs-postgres.metadata.0.name}"
  }
}

# resource "kubernetes_persistent_volume" "pv_gogs-postgres" {
#   metadata {
#     name = "pv-gogs-postgres"
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
#         path  = "/mnt/gogs-postgres"
#       }
#     }
#   }
# }
