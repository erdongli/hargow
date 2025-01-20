provider "google" {
  project = "hargow"
  region  = "us-central1"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  alias = "c0"
  host  = "https://${resource.google_container_cluster.c0.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    resource.google_container_cluster.c0.master_auth[0].cluster_ca_certificate,
  )
}
