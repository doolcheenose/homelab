resource "kubernetes_namespace" "radarr" {
  metadata {
    name = "radarr"
  }
}
