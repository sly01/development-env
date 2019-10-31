provider "kubernetes" {
  
}

resource "kubernetes_namespace" "ns_development" {
  metadata {
    name = "development"
  }
}

resource "kubernetes_deployment" "jenkins" {
  metadata {
    name = "jenkins"
    labels = {
      app = "jenkins"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jenkins"
      }
    }

    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }

      spec {
        container {
          image = "jenkins/jenkins:lts"
          name  = "jenkins"

          port {
            container_port = 8080
          }
          
          port {
            container_port = 50000
          }

          volume_mount {
            mount_path = "/var/jenkins_home"
            name = "jenkins-volume"
          }
        }
        volume {
            name = "jenkins-volume"
            persistent_volume_claim {
              claim_name = "${kubernetes_persistent_volume_claim.pvc_jenkins.metadata.0.name}"
            }
          }
      }
    }
  }
}
resource "kubernetes_service" "svc_jenkins" {
  metadata {
    name = "jenkins"
  }
  spec {
    selector = {
      app = "jenkins"
    }
    
    port {
      name        = "web-ui"
      port        = 8080
      target_port = 8080
      node_port   = 32581
    }

    port {
      name        = "build-executor"
      port        = 50000
      target_port = 50000
      node_port   = 32582
    }
    type = "NodePort"
  }
}

resource "kubernetes_persistent_volume_claim" "pvc_jenkins" {
  metadata {
    name = "pvc-jenkins"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "hostpath"
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.pv_jenkins.metadata.0.name}"
  }
}

resource "kubernetes_persistent_volume" "pv_jenkins" {
  metadata {
    name = "pv-jenkins"
   }
  spec {
    capacity = {
      storage = "2Gi"
    }
    persistent_volume_reclaim_policy = "Retain"
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "hostpath"
    persistent_volume_source {
      host_path  {
        path  = "/host_mnt/c/Users/Ahmet_Erkoc/.docker/Volumes/jenkins"
      }
    }
  }
}