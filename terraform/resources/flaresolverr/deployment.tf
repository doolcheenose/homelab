resource "kubernetes_deployment" "flaresolverr" {
  metadata {
    name      = "flaresolverr"
    namespace = "flaresolverr"
    labels = {
      "servarr.app" = "flaresolverr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "servarr.app" = "flaresolverr"
      }
    }

    template {
      metadata {
        labels = {
          "servarr.app" = "flaresolverr"
        }
      }

      spec {
        container {
          image = "ghcr.io/flaresolverr/flaresolverr:latest"
          name  = "flaresolverr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.flaresolverr_env.metadata.0.name
            }
          }
          port {
            container_port = 8191
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "flaresolverr_env" {
  metadata {
    name      = "flaresolverr-env"
    namespace = "flaresolverr"
  }
  data = {
    "LOG_LEVEL" = "info"
    # Not sure if these are supported
    # "PUID" = 1000
    # "PGID" = 1000
    "TZ" = "America/Los_Angeles"
  }
}
