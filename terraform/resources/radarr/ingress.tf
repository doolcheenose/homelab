resource "kubernetes_ingress_v1" "radarr" {
  metadata {
    name      = "radarr"
    namespace = var.namespace
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }
  spec {
    rule {
      host = "radarr.homelab.com"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "radarr"
              port {
                number = 7878
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service.radarr
  ]
}
