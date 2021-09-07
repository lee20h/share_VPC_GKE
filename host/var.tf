variable "project_id" {
  type = string
  default = "my-host-project"
}

variable "region" {
  type = string
  default = "asia-northeast3-a"
}

variable "bucket" {
  type = string
  default = "my-host-project-tf-state"
}

variable "sa_email" {
  type = string
  default = "my-service-account@my-host-project.iam.gserviceaccount.com"
}