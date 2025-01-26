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
    branches: [main]

env:
  PROJECT_ID: your-gcp-project-id
  GKE_CLUSTER: cluster1
  GKE_ZONE: your-gke-zone

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v0.2.0
      with:
        project_id: ${{ env.PROJECT_ID }}
        service_account_key: ${{ secrets.GKE_SA_KEY }}
        export_default_credentials: true

    - name: Get GKE credentials
      run: |
        gcloud container clusters get-credentials $GKE_CLUSTER --zone $GKE_ZONE

    - name: Set up Helm
      uses: azure/setup-helm@v1
      with:
        version: v3.4.0

    - name: Deploy Helm chart
      run: |
        helm upgrade --install ping ./ping \
          --set nodeSelector.cloud\.google\.com/gke-nodepool=isolatedGroup \
          --namespace default

#This workflow will do the following;
# - Trigger on pushes to the main branch
# - Set up the Google Cloud SDK
# - Authenticate with GKE
# - Set up Helm
# - Deploy the "ping" Helm chart to the "isolatedGroup" node pool in the GKE cluster
```
