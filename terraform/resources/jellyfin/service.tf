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

resource "kubernetes_service" "jellyfin_nodeport" {
  metadata {
    name      = "jellyfin-nodeport"
    namespace = var.namespace
  }

  spec {
    type = "NodePort"

    selector = {
      app = "jellyfin"
    }

    port {
      port        = 8096
      target_port = 8096
      node_port   = 30096
    }
  }
}
