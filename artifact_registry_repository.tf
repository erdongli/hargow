resource "google_artifact_registry_repository" "hargow" {
  location      = "us-central1"
  repository_id = "hargow"
  format        = "DOCKER"
}

