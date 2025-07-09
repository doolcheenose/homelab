resource "kubernetes_deployment" "radarr" {
  metadata {
    name      = "radarr"
    namespace = var.namespace
    labels = {
      "app" = "radarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "radarr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "radarr"
        }
      }

      spec {
        container {
          image = "linuxserver/radarr:5.27.1-nightly"
          name  = "radarr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.radarr_env.metadata.0.name
            }
          }
          port {
            container_port = 7878
          }
          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }
        volume {
          name = "config"
          host_path {
            path = "/srv/radarr/config"
            type = "Directory"
          }
        }
        volume {
          name = "data"
          host_path {
            path = "/srv/data"
            type = "Directory"
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "radarr_env" {
  metadata {
    name      = "radarr-env"
    namespace = var.namespace
  }
  data = {
    "PUID" = 1000
    "PGID" = 1000
    "TZ"   = "America/Los_Angeles"
  }
}
