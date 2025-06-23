resource "kubernetes_service" "radarr" {
  metadata {
    name      = "radarr"
    namespace = var.namespace
  }
  spec {
    type = "LoadBalancer"
    selector = {
      "app" = "radarr"
    }
    port {
      port = 7878
    }
  }
  depends_on = [
    kubernetes_deployment.radarr
  ]
}
