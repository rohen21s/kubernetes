# variables.tf - Defines input variables for the module.

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "XXXXX" # Add here project_id.
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "XXXXX" # Add here region.
}

variable "reference_registry" {
  description = "Reference Artifact Registry URL"
  type        = string
  default     = "reference.gcr.io" # Indicated and defined registry.
}

variable "instance_registry" {
  description = "Instance Artifact Registry URL"
  type        = string
  default     = "instance.gcr.io" # Indicated and defined registry.
}

variable "helm_chart_name" {
  description = "Name of the Helm chart to copy and deploy"
  type        = string
  default     = "ping"
}

variable "helm_chart_version" {
  description = "Version of the Helm chart to copy and deploy"
  type        = string
  default     = "0.1.0"
}
