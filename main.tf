terraform {
  required_version = "1.10.4"

  backend "gcs" {
    bucket = "hargow-terraform-backend"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.16.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
  }
}

provider "google" {
  project = "hargow"
  region  = "us-central1"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  alias                  = "c0"
  host                   = "https://${module.gke_c0.endpoint}"
  cluster_ca_certificate = base64decode(module.gke_c0.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

resource "google_artifact_registry_repository" "docker" {
  repository_id = "docker"
  format        = "DOCKER"
}

resource "google_compute_network" "n0" {
  name = "n0"

  auto_create_subnetworks = false
}

module "gke_c0" {
  source                          = "./modules/gke"
  name                            = "c0"
  artifact_registry_repository_id = google_artifact_registry_repository.docker.repository_id
  network_id                      = google_compute_network.n0.id
  ip_cidr_range                   = "10.0.0.0/16"
  services_ip_cidr_range          = "192.168.0.0/24"
  pods_ip_cidr_range              = "192.168.1.0/24"
}

module "server_www" {
  source = "./modules/server"
  providers = {
    kubernetes = kubernetes.c0,
  }
  name = "www"
  domains = [
    "erdongli.com",
    "www.erdongli.com",
  ]
}
