provider "google" {
  credentials = "${file(var.path)}" 
  project     = "imap-solution-for-cnd" 
  region      = "us-central1" 
  zone        = "us-central1-a" 
}

resource "google_container_cluster" "primary" {
  name     = "terraform-demo-cluster" 
  location = "us-central1-a" 

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  
  remove_default_node_pool = true 
  initial_node_count       = 1 

  #master_auth {
  #  username = "" 
  #  password = ""
  #
  #  client_certificate_config {
  #    issue_client_certificate = false
  #  }
  #}
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "terraform-node-pool" 
  location   = "us-central1-a" 
  cluster    = google_container_cluster.primary.name 
  node_count = 1 

  node_config { 
    preemptible  = true 
    machine_type = "n1-standard-1" 

    metadata = { 
      disable-legacy-endpoints = "true" 
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

data "google_container_cluster" "my_cluster" {
  name     = "terraform-demo-cluster"
  location = "us-central1-a"
}

output "cluster-name" {
  value = data.google_container_cluster.my_cluster.name
}

output "endpoint" {
  value = data.google_container_cluster.my_cluster.endpoint
}