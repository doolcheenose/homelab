resource "kubernetes_namespace" "homelab" {
  metadata {
    name = var.namespace
  }
}
