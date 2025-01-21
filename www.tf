resource "google_compute_address" "www" {
  name = "www"
}

resource "kubernetes_namespace" "www" {
  provider = kubernetes.c0

  metadata {
    name = "www"

    labels = {
      app = "www"
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

      labels = {
        app = "www"
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

resource "kubernetes_manifest" "managed_certificate_www" {
  provider = kubernetes.c0

  manifest = {
    apiVersion = "networking.gke.io/v1"
    kind       = "ManagedCertificate"

    metadata = {
      name      = "www"
      namespace = kubernetes_namespace.www.metadata[0].name

      labels = {
        app = "www"
      }
    }

    spec = {
      domains = ["erdongli.com", "www.erdongli.com"]
    }
  }
}
