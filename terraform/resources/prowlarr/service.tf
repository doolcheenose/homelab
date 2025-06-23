resource "kubernetes_service" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = var.namespace
  }
  spec {
    type = "LoadBalancer"
    selector = {
      "app" = "prowlarr"
    }
    port {
      port = 9696
    }
  }
  depends_on = [
    kubernetes_deployment.prowlarr
  ]
}
