resource "kubernetes_deployment" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = var.namespace
    labels = {
      "app" = "prowlarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "prowlarr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "prowlarr"
        }
      }

      spec {
        container {
          image = "lscr.io/linuxserver/prowlarr:develop"
          name  = "prowlarr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.prowlarr_env.metadata.0.name
            }
          }
          port {
            container_port = 9696
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
        }
        volume {
          name = "data"
          host_path {
            path = "/srv/prowlarr/config"
            type = "Directory"
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "prowlarr_env" {
  metadata {
    name      = "prowlarr-env"
    namespace = var.namespace
  }
  data = {
    "PUID" = 1000
    "PGID" = 1000
    "TZ"   = "America/Los_Angeles"
  }
}
