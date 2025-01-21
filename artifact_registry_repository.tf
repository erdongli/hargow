resource "google_artifact_registry_repository" "hargow" {
  location      = "us-central1"
  repository_id = "hargow"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "c0" {
  location   = google_artifact_registry_repository.hargow.location
  repository = google_artifact_registry_repository.hargow.repository_id

  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.c0.email}"
}
