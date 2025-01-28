# Challenge 3

---
### Context - Task
> Create a Github workflow to allow installing helm chart from Challenge1 using module from Challenge2
> into a GKE cluster (considering a preexisting resource group and cluster name).

---
### Solution

> Github workflow code snippet / simulation would be similar to the following `deploy-to-gke.yml` file in order to achieve Challenge 3;
> 
> To make this work, we should place the workflow file in the`.github/workflows/` directory.
> 
> Therefore GitHub will automatically recognize and use it to run your workflow. 
> 
> The `deploy-to-gke.yml` file should contain workflow configuration, including the necessary steps to deploy to GKE Cluster.

```yaml
# To make this work, we should place the workflow file in the`.github/workflows/` directory.
name: Deploy to GKE

on:
  push:
    branches:
      - main
  workflow_dispatch:

env:
  PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  GKE_CLUSTER: your-cluster-name
  GKE_ZONE: your-cluster-zone

jobs:
  deploy:
    name: Deploy to GKE
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup gcloud CLI
        uses: google-github-actions/setup-gcloud@v2
        with:
          service_account_key: ${{ secrets.GCP_SA_KEY }}
          project_id: ${{ env.PROJECT_ID }}

      - name: Get GKE credentials
        run: |
          gcloud container clusters get-credentials ${{ env.GKE_CLUSTER }} --zone ${{ env.GKE_ZONE }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: |
          cd challenge2
          terraform init

      - name: Terraform Plan
        run: |
          cd challenge2
          terraform plan -out=tfplan

      - name: Terraform Apply
        run: |
          cd challenge2
          terraform apply -auto-approve tfplan

      - name: Install Helm
        uses: azure/setup-helm@v3
        with:
          version: v3.12.1

      - name: Deploy Helm Chart
        run: |
          helm upgrade --install ping-app ../challenge1/ping-0.1.0.tgz
          
#This workflow will do the following;
# - Trigger on pushes to the main branch.
# - #Make sure you reference correctly environment variables for the GCP PROJECT_ID, GKE_CLUSTER, and GKE_ZONE variables.
# - Sets up gcloud CLI.
# - Authenticates with GKE. It gets the GKE cluster credentials to allow interaction with the cluster.
# - Sets up Terraform, init plan and apply, our terraform configuration from /challenge2.
# - Sets up Helm in order to be able to deploy helm chart from challenge1/ping-0.1.0.tgz.
# - - - - - 
# - NOTE: 
#   - This workflow assumes that your GKE cluster already exists. 
#   - Make sure to replace your-cluster-name and your-cluster-zone with your actual GKE cluster details. 
#   - Also, ensure that you have the following secrets set up in your GitHub repository:
#     - GCP_PROJECT_ID: Your Google Cloud project ID
#     - GCP_SA_KEY: The service account key with necessary permissions to access GKE and deploy resources
```
