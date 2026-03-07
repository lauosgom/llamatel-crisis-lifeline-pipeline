variable "credentials" {
  description = "Path to GCP credentials JSON file"
  default     = "./keys/credentials.json"
}

variable "project_id" {
  description = "Project ID"
  default     = "singular-arbor-401018"
}

variable "location" {
  description = "Project Location"
  default     = "US"
}

variable "region" {
  description = "Project Region"
  default     = "us-east1"
}

variable "bq_dataset_name" {
  description = "BigQuery Dataset Name"
  default     = "calls_dataset"
}

variable "bq_dataset_name_demo" {
  description = "BigQuery Dataset Name for demo and practice zoomcamp"
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "GCS Bucket Name"
  default     = "singular-arbor-401018-calls-bucket"
}

variable "gs_storage_class" {
  description = "GCS Storage Class"
  default     = "STANDARD"
}