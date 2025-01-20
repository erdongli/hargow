terraform {
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

resource "google_storage_bucket" "backend" {
  name     = "hargow-terraform-backend"
  location = "US"

  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
