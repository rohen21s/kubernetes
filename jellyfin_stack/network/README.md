# Network

### Requirements
- **MetalLB**
- **NGINX Ingress-controller**



---
### MetalLB installation

Required to `lease` and `assign` IP addresses to `LoadBalancer` type of `svc` from your defined `IPAddressPool` at the same time to do `L2Advertisement`.

```shell
# Install MetalLB components.
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml 
```

```yaml
# Define L2Advertisement with named "ipAddressPools" in my case is "defaultpool".
# l2advertisement.yaml

apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
    - defaultpool
```

```yaml
# Choose correctly an IP range from your home network, be careful to not select already used IPs.
# defaultpool.yaml

apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: defaultpool
  namespace: metallb-system
spec:
  addresses:
    - 192.168.1.200-192.168.1.240
```

>[!Note]
> You can check all the manifests for reference [here](github.com/rohen21s/kubernetes/tree/main/jellyfin_stack/network/metalb).

---
### NGINX Ingress-controller installation

Required to control the `access` and `path` to our services later using `DNS`.

>[!Note]
> - The latest stable release version `4.0.1`, which was released on `February 7, 2025`. 
> - This version is compatible with `Kubernetes versions 1.25 to 1.32`.
> - This installation process will deploy `NGINX Ingress Controller version 4.0.1` in your kubernetes cluster using `Helm`. 
> ---
> **#Key Parameters:** <br>
> **--version 2.0.1**   #Specifies the Helm chart version (required for compatibility). <br>
> **--set controller.image.tag=4.0.1**   #Explicitly sets the NGINX Ingress Controller version. <br>
> **--namespace ingress-nginx**   #Deploys to a dedicated namespace. <br>
> **--create-namespace**   #Creates the namespace if it doesn’t exist.

 ```shell
#copy paste all this in terminal
#To install NGINX Ingress Controller version 4.0.1 using Helm, follow these steps:
helm install nginx4-0-1 oci://ghcr.io/nginx/charts/nginx-ingress \
--version 2.0.1 \ 
--namespace ingress-nginx \
--create-namespace \
--set controller.image.tag=4.0.1

#Verify the installation:
kubectl get pods -n ingress-nginx -o wide
kubectl exec -it -n ingress-nginx $(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=nginx-ingress -o jsonpath='{.items[0].metadata.name}') -- /nginx-ingress --version

#Check the external IP or hostname assigned to the Ingress Controller service:
kubectl get services -n ingress-nginx -o wide
kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=nginx-ingress -o jsonpath='{.items[0].metadata.name}' -o yaml | grep image:
```