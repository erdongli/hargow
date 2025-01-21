locals {
  name = "www"

  domains = [
    "erdongli.com",
    "www.erdongli.com",
  ]
}

resource "google_compute_address" "www" {
  name = local.name
}

resource "kubernetes_namespace" "www" {
  provider = kubernetes.c0

  metadata {
    name = local.name

    labels = {
      app = local.name
    }
  }
}

resource "kubernetes_service" "www" {
  provider = kubernetes.c0

  metadata {
    name      = local.name
    namespace = kubernetes_namespace.www.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = local.name
    }

    port {
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_manifest" "managed_certificate_www" {
  provider = kubernetes.c0

  manifest = {
    apiVersion = "networking.gke.io/v1"
    kind       = "ManagedCertificate"

    metadata = {
      name      = local.name
      namespace = kubernetes_namespace.www.metadata[0].name

      labels = {
        app = local.name
      }
    }

    spec = {
      domains = local.domains
    }
  }
}

resource "kubernetes_manifest" "frontend_config_www" {
  provider = kubernetes.c0

  manifest = {
    apiVersion = "networking.gke.io/v1beta1"
    kind       = "FrontendConfig"

    metadata = {
      name      = local.name
      namespace = kubernetes_namespace.www.metadata[0].name

      labels = {
        app = local.name
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

resource "kubernetes_ingress_v1" "www" {
  provider = kubernetes.c0

  metadata {
    name      = local.name
    namespace = kubernetes_namespace.www.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                 = "gce"
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_address.www.name
      "networking.gke.io/managed-certificates"      = kubernetes_manifest.managed_certificate_www.manifest.metadata.name
      "networking.gke.io/v1beta1.FrontendConfig"    = kubernetes_manifest.frontend_config_www.manifest.metadata.name
    }
  }

  spec {
    dynamic "rule" {
      for_each = local.domains

      content {
        host = rule.value

        http {
          path {
            path      = "/"
            path_type = "Prefix"

            backend {
              service {
                name = kubernetes_service.www.metadata[0].name

                port {
                  number = kubernetes_service.www.spec[0].port[0].port
                }
              }
            }
          }
        }
      }
    }
  }
}
