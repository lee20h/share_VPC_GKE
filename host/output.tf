output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "network" {
  value       = google_compute_network.vpc.name
  description = "GCP Network"
}

output "subnet" {
  value       = google_compute_subnetwork.tier-1.name
  description = "tier1 subnet"
}