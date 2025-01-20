resource "google_compute_network" "n0" {
  name = "n0"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "n0s0" {
  name = "s0"

  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"

  stack_type = "IPV4_ONLY"

  network = google_compute_network.n0.id
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "192.168.1.0/24"
  }
}

resource "google_container_cluster" "c0" {
  name = "c0"

  location         = "us-central1"
  enable_autopilot = true

  network    = google_compute_network.n0.id
  subnetwork = google_compute_subnetwork.n0s0.id

  ip_allocation_policy {
    stack_type                    = "IPV4"
    services_secondary_range_name = google_compute_subnetwork.n0s0.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.n0s0.secondary_ip_range[1].range_name
  }

  deletion_protection = false
}
