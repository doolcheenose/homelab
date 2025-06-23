resource "kubernetes_service" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = "prowlarr"
  }
  spec {
    type = "LoadBalancer"
    selector = {
      "servarr.app" = "prowlarr"
    }
    port {
      port = 9696
    }
  }
  depends_on = [
    kubernetes_deployment.prowlarr
  ]
}
