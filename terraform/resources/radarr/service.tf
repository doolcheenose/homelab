resource "kubernetes_service" "radarr" {
  metadata {
    name      = "radarr"
    namespace = "radarr"
  }
  spec {
    type = "LoadBalancer"
    selector = {
      "servarr.app" = "radarr"
    }
    port {
      port = 7878
    }
  }
  depends_on = [
    kubernetes_deployment.radarr
  ]
}
