resource "google_service_account" "this" {
  account_id = "gke-${var.name}"
}

resource "google_artifact_registry_repository_iam_member" "this" {
  repository = var.artifact_registry_repository_id

  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.this.email}"
}

resource "google_compute_subnetwork" "this" {
  name = var.name

  ip_cidr_range = var.ip_cidr_range

  stack_type = "IPV4_ONLY"

  network = var.network_id
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_ip_cidr_range
  }

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_ip_cidr_range
  }
}

resource "google_container_cluster" "this" {
  name = var.name

  enable_autopilot = true

  network    = var.network_id
  subnetwork = google_compute_subnetwork.this.id

  ip_allocation_policy {
    stack_type                    = "IPV4"
    services_secondary_range_name = google_compute_subnetwork.this.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.this.secondary_ip_range[1].range_name
  }

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.this.email
    }
  }

  deletion_protection = false
}
