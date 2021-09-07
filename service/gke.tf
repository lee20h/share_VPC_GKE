terraform {
  backend "gcs" {
    bucket  = "my-host-project-tf-state"
    prefix  = "gke"
  }
}

resource "google_service_account" "default_sa" {
  account_id   = "my-host-project"
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

resource "google_compute_subnetwork_iam_binding" "binding" {
  members    = [
    "serviceAccount:my-host-project-number@cloudservices.gserviceaccount.com",
    "serviceAccount:my-host-project@my-host-project.iam.gserviceaccount.com",
    "serviceAccount:service-my-host-project-number@compute-system.iam.gserviceaccount.com",
    "serviceAccount:service-my-host-project-number@container-engine-robot.iam.gserviceaccount.com",
    ]
  project    = "green-ops"
  region     = "asia-northeast3"
  role       = "roles/compute.networkUser"
  subnetwork = "projects/green-ops/regions/asia-northeast3/subnetworks/tier-2"
}

resource "google_project_iam_binding" "hostService_iam" {
  members = [
    "serviceAccount:my-host-project-number@cloudservices.gserviceaccount.com",
    "serviceAccount:my-host-project@my-host-project.iam.gserviceaccount.com",
    "serviceAccount:service-my-host-project-number@compute-system.iam.gserviceaccount.com",
    "serviceAccount:service-my-host-project-number@container-engine-robot.iam.gserviceaccount.com",
  ]
  project = "my-host-project"
  role    = "roles/container.hostServiceAgentUser"
}

 resource "google_project_iam_binding" "security_iam" {
  members = [
    "serviceAccount:my-host-project-number@cloudservices.gserviceaccount.com",
     "serviceAccount:my-host-project@my-host-project.iam.gserviceaccount.com",
     "serviceAccount:service-my-host-project-number@compute-system.iam.gserviceaccount.com",
     "serviceAccount:service-my-host-project-number@container-engine-robot.iam.gserviceaccount.com",
  ]
  project = "my-host-project"
  role    = "roles/compute.securityAdmin"
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
  network    = "projects/my-host-project/global/networks/my-host-project-vpc"
  subnetwork = "projects/my-host-project/regions/asia-northeast3/subnetworks/tier-2"
  networking_mode          = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name = "tier-2-pods"
    services_secondary_range_name = "tier-2-services"
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "tier2-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
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
