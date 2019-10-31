provider "kubernetes" {
  
}

resource "kubernetes_namespace" "ns_development" {
  metadata {
    name = "development"
  }
}

resource "kubernetes_deployment" "gogs-mysql" {
  metadata {
    name = "gogs-mysql"
    labels = {
      app = "gogs-mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gogs-mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "gogs-mysql"
        }
      }

      spec {
        container {
          image = "mysql:5.7"
          name  = "gogs-mysql"

          port {
            container_port = 3306
          }
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value = "123456"
          }
          env {
            name = "MYSQL_DATABASE"
            value = "gogs"
          }
          volume_mount {
            mount_path = "/var/lib/mysql"
            name = "gogs-mysql-volume"
          }
        }
        volume {
            name = "gogs-mysql-volume"
            persistent_volume_claim {
              claim_name = "${kubernetes_persistent_volume_claim.pvc_gogs-mysql.metadata.0.name}"
            }
          }
      }
    }
  }
}

resource "kubernetes_deployment" "gogs" {
  metadata {
    name = "gogs"
    labels = {
      app = "gogs"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gogs"
      }
    }

    template {
      metadata {
        labels = {
          app = "gogs"
        }
      }

      spec {
        # init_container {
        #   name = "config-data"
        #   image = "busybox"
        #   command = ["sh", "-c", "chmod 600 -R /data/ssh"]
        #   volume_mount {
        #     mount_path = "/data"
        #     name = "gogs-volume"
        #   }
        # }
        container {
          image = "gogs/gogs:latest"
          name  = "gogs"

          port {
            container_port = 22
          }
          port {
            container_port = 3000
          }
          env {
            name = "RUN_CROND"
            value = "true"
          }
          volume_mount {
            mount_path = "/data"
            name = "gogs-volume"
          }
        }
        volume {
            name = "gogs-volume"
            host_path {
              path = "/host_mnt/c/Users/Ahmet_Erkoc/.docker/Volumes/gogs-local"
            }
          }
      }
    }
  }
}

resource "kubernetes_service" "svc_gogs" {
  metadata {
    name = "gogs"
  }
  spec {
    selector = {
      app = "gogs"
    }
    
    port {
      name        = "web-ui"
      port        = 3000
      target_port = 3000
      node_port   = 32500
    }

    port {
      name        = "ssh-access"
      port        = 10022
      target_port = 22
      node_port   = 32501
    }
    type = "NodePort"
  }
}

resource "kubernetes_service" "svc_gogs-mysql" {
  metadata {
    name = "gogs-mysql"
  }
  spec {
    selector = {
      app = "gogs-mysql"
    }
    
    port {
      name        = "web-ui"
      port        = 3306
    }
    type = "ClusterIP"
  }
}
resource "kubernetes_persistent_volume_claim" "pvc_gogs-mysql" {
  metadata {
    name = "pvc-gogs-mysql"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "hostpath"
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.pv_gogs-mysql.metadata.0.name}"
  }
}

resource "kubernetes_persistent_volume" "pv_gogs-mysql" {
  metadata {
    name = "pv-gogs-mysql"
   }
  spec {
    capacity = {
      storage = "5Gi"
    }
    persistent_volume_reclaim_policy = "Retain"
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "hostpath"
    persistent_volume_source {
      host_path  {
        path  = "/host_mnt/c/Users/Ahmet_Erkoc/.docker/Volumes/gogs-mysql"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "pvc_gogs" {
  metadata {
    name = "pvc-gogs"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "hostpath"
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.pv_gogs.metadata.0.name}"
  }
}

resource "kubernetes_persistent_volume" "pv_gogs" {
  metadata {
    name = "pv-gogs"
   }
  spec {
    capacity = {
      storage = "5Gi"
    }
    persistent_volume_reclaim_policy = "Retain"
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "hostpath"
    persistent_volume_source {
      host_path  {
        path  = "/host_mnt/c/Users/Ahmet_Erkoc/.docker/Volumes/gogs"
      }
    }
  }
}