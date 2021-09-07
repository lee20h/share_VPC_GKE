variable "project_id" {
  type = string
  default = "my-service-project"
}

variable "region" {
  type = string
  default = "asia-northeast3-a"
}

variable "bucket" {
  type = string
  default = "my-service-project-tf-state"
}

variable "sa_email" {
  type = string
  default = "my-service-project@my-service-project.iam.gserviceaccount.com"
}