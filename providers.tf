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
