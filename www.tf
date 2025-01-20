resource "google_compute_address" "www" {
  name = "www"
}

resource "kubernetes_namespace" "www" {
  provider = kubernetes.c0

  metadata {
    annotations = {
      name = "www"
    }

    labels = {
      name = "www"
    }

    name = "www"
  }
}
