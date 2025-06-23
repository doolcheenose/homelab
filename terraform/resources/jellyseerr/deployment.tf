resource "kubernetes_deployment" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = var.namespace
    labels = {
      "app" = "jellyseerr"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "jellyseerr"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "jellyseerr"
        }
      }

      spec {
        container {
          image = "fallenbagel/jellyseerr:latest"
          name  = "jellyseerr"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.jellyseerr.metadata.0.name
            }
          }
          port {
            container_port = 5055
            name           = "http"
          }
          volume_mount {
            name       = "config"
            mount_path = "/app/config"
          }
        }
        volume {
          name = "config"
          host_path {
            path = "/srv/jellyseerr/config"
            type = "Directory"
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = var.namespace
  }
  data = {
    "LOG_LEVEL" = "debug"
    "TZ"        = "America/Los_Angeles"
  }
}
