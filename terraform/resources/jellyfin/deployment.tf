resource "kubernetes_deployment" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    labels = {
      "app" = "jellyfin"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "jellyfin"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "jellyfin"
        }
      }

      spec {
        container {
          name  = "jellyfin"
          image = "jellyfin/jellyfin:latest"
          # env_from {
          #   config_map_ref {
          #     name = kubernetes_config_map.jellyfin_env.metadata.0.name
          #   }
          # }
          port {
            name           = "web"
            container_port = 8096
          }
          # port {
          #   name           = "local-discovery"
          #   container_port = 7359
          # }
          # port {
          #   name           = "dlna"
          #   container_port = 1900
          # }
          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
          volume_mount {
            name       = "cache"
            mount_path = "/cache"
          }
          volume_mount {
            name       = "media"
            mount_path = "/media"
          }
          security_context {
            run_as_user                = 1000
            run_as_group               = 1000
            allow_privilege_escalation = false
            run_as_non_root            = true
          }
          resources {
            requests = {
              cpu = 2
            }
            limits = {
              cpu = 4
            }
          }
        }
        volume {
          name = "config"
          host_path {
            path = "/srv/jellyfin/config"
          }
        }
        volume {
          name = "cache"
          host_path {
            path = "/srv/jellyfin/media"
          }
        }
        volume {
          name = "media"
          host_path {
            path = "/srv/jellyfin/media"
          }
        }
      }
    }
  }
}
