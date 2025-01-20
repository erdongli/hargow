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

