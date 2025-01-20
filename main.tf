terraform {
  backend "gcs" {
    bucket  = "hargow-terraform-backend"
    prefix  = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.16.0"
    }
  }

  required_version = "1.10.4"
}

provider "google" {
  project = "hargow"
  region  = "us-central1"
}
