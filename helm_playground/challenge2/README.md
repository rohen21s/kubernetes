# Challenge 2

---
### Context - Task
> We have a private registry based on GCP Artifact Registry where we publish all our
> Helm charts. Let’s call this registry **`reference.gcr.io`**. When we create a GKE cluster, we
> also create another GCP Artifact Registry where we need to copy the Helm charts we
> are going to install in that GKE from the reference registry. Let’s call this registry
> **`instance.gcr.io`**.

> Provide an automation for the described process using the tool you
> feel more comfortable with (**terraform** or **ansible** are preferred).
> You can assume the caller will be authenticated in GCP with enough permissions to
> import Helm charts into the instance registry and will provide the module a configured
> helm provider.

---
### Solution

- I've chosen "Terraform" option and its GCP modules, in order to automate the process of copying Helm charts from a reference registry to an instance registry and deploying them to a GKE cluster, with the following Terraform configuration:

```text
challenge2/
├── main.tf - Contains the primary Terraform configuration with resources and providers.
├── variables.tf - Defines input variables for the module.
├── outputs.tf - Defines any output values you want to expose.
└── versions.tf - This file content it can be simply added to main.tf however for the best practices of management Terraform tool it is ok to have this code block separated, which specifies provider versions and Terraform requirements.
```

>[!Note]
> It's important to note that all the following requirements are met before running this configuration:
> - Terraform CLI tool installed on the environment.
> - Authenticated with GCP, Google Cloud SDK (gcloud) installed and configured with appropriate permissions.
> - A GKE cluster already set up and running.
> - Installed the required CLI tools (gcloud and helm).
> - The ping-0.1.0.tgz helm chart package available in your reference registry (reference.gcr.io).
> - Values assigned correctly to the environment variables (variables.tf) for the required variables (project_id, region, etc.)

- Next step, once all that is set-up and prerequisites in place, run the Terraform commands in the directory containing your .tf files:

```text
terraform init
terraform plan
terraform apply
```