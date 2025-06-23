resource "kubernetes_service" "flaresolverr" {
  metadata {
    name      = "flaresolverr"
    namespace = var.namespace
  }
  spec {
    type = "LoadBalancer"
    selector = {
      "app" = "flaresolverr"
    }
    port {
      port = 8191
    }
  }
  depends_on = [
    kubernetes_deployment.flaresolverr
  ]
}

