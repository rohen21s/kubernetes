# Network
___

### Requirements

>
> - **MetalLB<br>**
> - **NGINX Ingress-controller**


### MetalLB installation

<br>

### NGINX Ingress-controller installation
>
> - The latest stable release version `4.0.1`, which was released on `February 7, 2025`. This version is compatible with `Kubernetes versions 1.25 to 1.32`.
> - This installation process will deploy `NGINX Ingress Controller version 4.0.1` in your kubernetes cluster using `Helm`.
> 
> ```shell
> #copy paste all this in terminal
> #To install NGINX Ingress Controller version 4.0.1 using Helm, follow these steps:
> helm install nginx4-0-1 oci://ghcr.io/nginx/charts/nginx-ingress \
> --version 2.0.1 \
> --namespace ingress-nginx \
> --create-namespace \
> --set controller.image.tag=4.0.1
>
> #Verify the installation:
> kubectl get pods -n ingress-nginx -o wide
> kubectl exec -it -n ingress-nginx $(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=nginx-ingress -o jsonpath='{.items[0].metadata.name}') -- /nginx-ingress --version
> 
> #Check the external IP or hostname assigned to the Ingress Controller service:
> kubectl get services -n ingress-nginx -o wide
> kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=nginx-ingress -o jsonpath='{.items[0].metadata.name}' -o yaml | grep image:
> ```

> [!NOTE]
> **#Key Parameters:** <br>
> **--version 2.0.1**   #Specifies the Helm chart version (required for compatibility). <br>
> **--set controller.image.tag=4.0.1**   #Explicitly sets the NGINX Ingress Controller version. <br>
> **--namespace ingress-nginx**   #Deploys to a dedicated namespace. <br>
> **--create-namespace**   #Creates the namespace if it doesn’t exist.




>
>**[Explore the Kubernetes Home Lab](https://github.com/rohen21s/kubernetes/tree/main/kube_config)**

>
> `kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml`
> 
> 
<br>

