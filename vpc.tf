terraform {
  backend "gcs" {
    bucket  = "vpc-tf-state"
    prefix  = "vpc"
  }
}

# A host project provides network resources to associated service projects.
resource "google_compute_shared_vpc_host_project" "host" {
  project = "my-host-project"
}

# A service project gains access to network resources provided by its
# associated host project.
resource "google_compute_shared_vpc_service_project" "service1" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = "my-service-project"
}