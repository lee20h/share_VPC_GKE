terraform {
  backend "gcs" {
    bucket  = "my-host-project-tf-state"
    prefix  = "gke"
  }
}

resource "google_service_account" "default_sa" {
  account_id   = "my-service-account"
  display_name = "Terraform"
  project      = var.project_id
}

resource "google_project_iam_binding" "container_iam" {
  project = var.project_id
  role    = "roles/container.admin"
  members = [
    "serviceAccount:${var.sa_email}",
  ]
}

resource "google_project_iam_binding" "storage_iam" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = [
    "serviceAccount:${var.sa_email}",
  ]
}

resource "google_project_iam_binding" "containerRegistry_iam" {
  project = var.project_id
  role    = "roles/containerregistry.ServiceAgent"
  members = [
    "serviceAccount:${var.sa_email}",
  ]
}

resource "google_project_iam_binding" "serviceAccount_iam" {
  project = var.project_id
  role    = "roles/iam.serviceAccountAdmin"
  members = [
    "serviceAccount:${var.sa_email}",
  ]
}

resource "google_project_iam_binding" "source_iam" {
  project = var.project_id
  role    = "roles/source.admin"
  members = [
    "serviceAccount:${var.sa_email}",
  ]
}

resource "google_project_iam_binding" "network_iam" {
  project = var.project_id
  role    = "roles/compute.networkUser"
  members = [
    "serviceAccount:${var.sa_email}",
  ]
}

resource "google_project_iam_binding" "logging_iam" {
  project = var.project_id
  role    = "roles/logging.admin"
  members = [
    "serviceAccount:${var.sa_email}",
  ]
}

resource "google_project_iam_binding" "monitoring_iam" {
  project = var.project_id
  role    = "roles/monitoring.admin"
  members = [
    "serviceAccount:${var.sa_email}",
  ]
}

resource "google_project_iam_binding" "hostService_iam" {
  project = var.project_id
  role    = "roles/container.hostServiceAgentUser"
  members = [
    "serviceAccount:${var.sa_email}",
    "serviceAccount:my-service-project@cloudservices.gserviceaccount.com",
    "serviceAccount:service-my-service-project@container-engine-robot.iam.gserviceaccount.com",
    "serviceAccount:service-my-service-project@compute-system.iam.gserviceaccount.com"
  ]
}

variable "gke_num_nodes" {
  default     = 6
  description = "number of gke nodes"
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "my-host-cluster"
  location = var.region
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = "1.20.8-gke.900"
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.tier-1.name
  networking_mode          = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name = "tier-1-pods"
    services_secondary_range_name = "tier-1-services"
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "tier1-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      env = var.project_id
    }
    service_account = var.sa_email
    machine_type = "e2-medium"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
