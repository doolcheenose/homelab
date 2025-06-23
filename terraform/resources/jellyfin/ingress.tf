resource "kubernetes_ingress_v1" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = var.namespace
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }
  spec {
    rule {
      host = "jellyfin.homelab.com"
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
