# main.tf - Contains the primary Terraform configuration with resources and providers.

resource "google_artifact_registry_repository" "instance_repo" {
  provider = google
  project  = var.project_id
  location = var.region
  repository_id = "instance-helm-repo"
  format = "DOCKER"
}

resource "null_resource" "copy_helm_chart" {
  provisioner "local-exec" {
    command = <<-EOT
      gcloud auth configure-docker ${var.reference_registry} --quiet
      gcloud auth configure-docker ${var.instance_registry} --quiet
      helm pull oci://${var.reference_registry}/${var.helm_chart_name} --version ${var.helm_chart_version}
      helm push ${var.helm_chart_name}-${var.helm_chart_version}.tgz oci://${var.instance_registry}
    EOT
  }

  depends_on = [google_artifact_registry_repository.instance_repo]
}

resource "helm_release" "ping_app" {
  name       = var.helm_chart_name
  repository = "oci://${var.instance_registry}"
  chart      = var.helm_chart_name
  version    = var.helm_chart_version

  depends_on = [null_resource.copy_helm_chart]
}
