resource "kubernetes_namespace" "prowlarr" {
  metadata {
    name = "prowlarr"
  }
}
