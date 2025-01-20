resource "google_compute_address" "www" {
  name = "www"
}

resource "google_artifact_registry_repository" "www" {
  location      = "us-central1"
  repository_id = "www"
  format        = "DOCKER"
}

resource "kubernetes_namespace" "www" {
  provider = kubernetes.c0

  metadata {
    name = "www"

    annotations = {
      name = "www"
    }

    labels = {
      name = "www"
    }
  }
}

resource "kubernetes_manifest" "frontend_config_www" {
  provider = kubernetes.c0

  manifest = {
    apiVersion = "networking.gke.io/v1beta1"
    kind       = "FrontendConfig"

    metadata = {
      name      = "www"
      namespace = kubernetes_namespace.www.metadata[0].name

      annotations = {
        name = "www"
      }

      labels = {
        name = "www"
      }
    }

    spec = {
      redirectToHttps = {
        enabled          = true
        responseCodeName = "301"
      }
    }
  }
}
