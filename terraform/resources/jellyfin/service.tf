resource "kubernetes_service" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = var.namespace
  }
  spec {
    selector = {
      "app" = "jellyfin"
    }
    type = "LoadBalancer"
    port {
      name        = "web"
      protocol    = "TCP"
      port        = 8096
      target_port = "web"
    }
  }
  depends_on = [
    kubernetes_deployment.jellyfin
  ]
}
