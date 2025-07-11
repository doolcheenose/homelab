resource "kubernetes_ingress_v1" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = var.namespace
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }
  spec {
    rule {
      host = "prowlarr.home"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "prowlarr"
              port {
                number = 9696
              }
            }
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_service.prowlarr
  ]
}
