resource "kubernetes_deployment" "radarr" {
  metadata {
    name      = "radarr"
    namespace = "radarr"
    labels = {
      "servarr.app" = "radarr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "servarr.app" = "radarr"
      }
    }

    template {
      metadata {
        labels = {
          "servarr.app" = "radarr"
        }
      }

      spec {
        container {
          image = "lscr.io/linuxserver/radarr:4.2.4"
          name  = "radarr"
          env {
            name  = "PUID"
            value = 1000
          }
          env {
            name  = "PGID"
            value = 1000
          }
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
            name       = "movies"
            mount_path = "/movies"
          }
          volume_mount {
            name       = "import"
            mount_path = "/import"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/downloads"
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
          name = "movies"
          host_path {
            path = "/srv/data/media/library/movies"
            type = "Directory"
          }
        }
        volume {
          name = "import"
          host_path {
            path = "/srv/data/media/library/import/movies"
            type = "Directory"
          }
        }
        volume {
          name = "downloads"
          host_path {
            path = "/srv/data/media/torrents/downloads"
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
    namespace = "radarr"
  }
  data = {
    "TZ" = "America/Los_Angeles"
  }
}
