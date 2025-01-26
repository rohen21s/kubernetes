# outputs.tf - Defines any output values you want to expose.

 output "instance_registry_url" {
   description = "URL of the created instance Artifact Registry"
   value       = google_artifact_registry_repository.instance_repo.name
 }

 output "helm_release_name" {
   description = "Name of the deployed Helm release"
   value       = helm_release.ping_app.name
 }
