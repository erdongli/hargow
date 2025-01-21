terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
  }
}

resource "google_compute_global_address" "this" {
  name = var.name
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.name

    labels = {
      app = var.name
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = var.name
    }

    port {
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_manifest" "managed_certificate" {
  manifest = {
    apiVersion = "networking.gke.io/v1"
    kind       = "ManagedCertificate"

    metadata = {
      name      = var.name
      namespace = kubernetes_namespace.this.metadata[0].name

      labels = {
        app = var.name
      }
    }

    spec = {
      domains = var.domains
    }
  }
}

resource "kubernetes_manifest" "frontend_config" {
  manifest = {
    apiVersion = "networking.gke.io/v1beta1"
    kind       = "FrontendConfig"

    metadata = {
      name      = var.name
      namespace = kubernetes_namespace.this.metadata[0].name

      labels = {
        app = var.name
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

resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.this.metadata[0].name

    labels = {
      app = var.name
    }

    annotations = {
      "kubernetes.io/ingress.class"                 = "gce"
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.this.name
      "networking.gke.io/managed-certificates"      = kubernetes_manifest.managed_certificate.manifest.metadata.name
      "networking.gke.io/v1beta1.FrontendConfig"    = kubernetes_manifest.frontend_config.manifest.metadata.name
    }
  }

  spec {
    dynamic "rule" {
      for_each = var.domains

      content {
        host = rule.value

        http {
          path {
            path      = "/"
            path_type = "Prefix"

            backend {
              service {
                name = kubernetes_service.this.metadata[0].name

                port {
                  number = kubernetes_service.this.spec[0].port[0].port
                }
              }
            }
          }
        }
      }
    }
  }
}
