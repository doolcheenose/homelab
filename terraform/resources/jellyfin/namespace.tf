resource "kubernetes_namespace" "jellyfin" {
  metadata {
    name = "jellyfin"
  }
}
