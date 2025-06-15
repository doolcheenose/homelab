resource "kubernetes_ingress_v1" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = kubernetes_namespace.jellyfin.metadata.0.name
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }
  spec {
    rule {
      host = "homelab.local"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "jellyfin"
              port {
                number = 8096
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service.jellyfin
  ]
}
