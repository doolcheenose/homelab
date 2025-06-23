resource "kubernetes_ingress_v1" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = var.namespace
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }
  spec {
    rule {
      host = "jellyseerr.homelab.com"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "jellyseerr"
              port {
                number = 5055
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service.jellyseerr
  ]
}
