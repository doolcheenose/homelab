resource "kubernetes_namespace" "jellyseerr" {
  metadata {
    name = "jellyseerr"
  }
}
