resource "kubernetes_service" "jellyseerr" {
  metadata {
    name      = "jellyseerr"
    namespace = kubernetes_namespace.jellyseerr.metadata.0.name
  }
  spec {
    type = "LoadBalancer"
    selector = {
      "app" = "jellyseerr"
    }
    port {
      name        = "http"
      port        = 5055
      target_port = "http"
    }
  }
  depends_on = [
    kubernetes_deployment.jellyseerr
  ]
}
