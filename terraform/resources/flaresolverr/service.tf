resource "kubernetes_service" "flaresolverr" {
  metadata {
    name      = "flaresolverr"
    namespace = "flaresolverr"
  }
  spec {
    type = "LoadBalancer"
    selector = {
      "servarr.app" = "flaresolverr"
    }
    port {
      port = 8191
    }
  }
  depends_on = [
    kubernetes_deployment.flaresolverr
  ]
}

