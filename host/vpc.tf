provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "share-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "tier-1" {
  name          = "tier-1"
  region        = "asia-northeast3"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.4.0/22"
  secondary_ip_range = [
    {
      range_name = "tier-1-services"
      ip_cidr_range = "10.0.32.0/20"
    },
    {
      range_name = "tier-1-pods"
      ip_cidr_range = "10.4.0.0/14"
    }
  ]
}

resource "google_compute_subnetwork" "tier-2" {
  name          = "tier-2"
  region        = "asia-northeast3"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "172.16.4.0/22"
  secondary_ip_range = [
    {
      range_name = "tier-2-services"
      ip_cidr_range = "172.16.16.0/20"
    },
    {
      range_name = "tier-2-pods"
      ip_cidr_range = "172.20.0.0/14"
    }
  ]
}