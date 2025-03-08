# Challenge 1

---
### Context - Task

> Modify the Ping Helm Chart to deploy the application on the following restrictions:
> - Isolate specific node groups forbidding the pods scheduling in these node groups.
> - Ensure that a pod will not be scheduled on a node that already has a pod of the same type.
> - Pods are deployed across different availability zones.
> - Ensure that another random service is up before applying the manifests.


---
### Solution

```text
# Summary of contents and changes made, contents of "ping-0.1.0.tgz"
- Includes `ping-0.1.0.tgz` helm package ready to install.
- Includes `README.md` file with all the detailed steps and comments done.
- For Challenge 1 - edited files with comments for each part, `deployment.yaml` `values.yaml` in the `ping-0.1.0.tgz` helm package.
```

- #1 Modifications, content added and splited into parts on the `values.yaml` manifest file.

```yaml
# Challenge 1 - ./ping/values.yaml
# Challenge 1 - Part 1 - Isolate specific node groups forbidding the pods scheduling in these node groups.
# NOTE: It is necessary to have beforehand these labels configured on our cluster, because pod will be in `pending` status.
nodeTaints:
  - key: "dedicated"
    value: "isolatedGroup"
    effect: "NoSchedule"

# Challenge 1 - Part 2 - Ensure that a pod will not be scheduled on a node that already has a pod of the same type.
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: "kubernetes.io/hostname"

# Challenge 1 - Part 3 - Pods are deployed across different availability zones.
# NOTE: It is necessary to have beforehand these zones configured on our cluster, because pod will be in `pending` status.
topologySpreadConstraints:
  maxSkew: 1
  topologyKey: "topology.kubernetes.io/zone"
  whenUnsatisfied: DoNotSchedule

# Challenge 1 - Part 4 - Ensure that another random service is up before applying the manifests.
initContainer:
  randomService:
    name: "random-service"
    port: 80
```


___

- #2 Modifications and content added on the `deployment.yaml` manifest file.

```yaml
# Challenge 1 - ./ping/templates/deployment.yaml
# Challenge 1 - START
# Challenge 1 - Part 1 - Isolate specific node groups forbidding the pods scheduling in these node groups.
  {{- if .Values.nodeTaints }}
tolerations:
  {{- toYaml .Values.nodeTaints | nindent 8 }}
  {{- end }}


# Challenge 1 - Part 2 - Ensure that a pod will not be scheduled on a node that already has a pod of the same type.
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app
              operator: In
              values:
                - {{ include "ping.name" . }}
        topologyKey: "kubernetes.io/hostname"


# Challenge 1 - Part 3 - Pods are deployed across different availability zones.
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfied: DoNotSchedule
    labelSelector:
      matchLabels:
        {{- include "ping.selectorLabels" . | nindent 12 }}


# Challenge 1 - Part 4 - Ensure that another random service is up before applying the manifests.
initContainers:
  - name: wait-for-service
    image: busybox
    command: ['sh', '-c', 'until nc -z {{ .Values.initContainer.randomService.name }} {{ .Values.initContainer.randomService.port }}; do echo waiting for {{ .Values.initContainer.randomService.name }}; sleep 15; done;']
# Challoenge 1 - END

```

---
### Testing 

- Testing part, we run `helm package ./ping` in order to obtain the `tgz` file and chart `testing-ping`. 
- Install that revision with `helm install testing-ping ./ping-o.1.0.tgz`

```shell

rohen@monstrussy-master:~/manifests-all/helms$ helm list
NAME                            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                                   APP VERSION
kube-prometheus-1735946771      default         2               2025-01-04 00:28:22.3870208 +0100 +0100 deployed        kube-prometheus-10.2.3                  0.79.2     
nfs-subdir-external-provisioner default         1               2025-01-11 17:31:35.62676548 +0000 UTC  deployed        nfs-subdir-external-provisioner-4.0.18  4.0.2      


rohen@monstrussy-master:~/manifests-all/helms$ ls
challenge1.rar  ping


rohen@monstrussy-master:~/manifests-all/helms$ helm package ./ping
Successfully packaged chart and saved it to: /home/rohen/manifests-all/helms/ping-0.1.0.tgz


rohen@monstrussy-master:~/manifests-all/helms$ helm install testing-ping ./ping-0.1.0.tgz
NAME: testing-ping
LAST DEPLOYED: Fri Jan 24 15:59:02 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=ping,app.kubernetes.io/instance=testing-ping" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
rohen@monstrussy-master:~/manifests-all/helms$ 


rohen@monstrussy-master:~/manifests-all/helms$ helm list
NAME                            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                                   APP VERSION
kube-prometheus-1735946771      default         2               2025-01-04 00:28:22.3870208 +0100 +0100 deployed        kube-prometheus-10.2.3                  0.79.2     
nfs-subdir-external-provisioner default         1               2025-01-11 17:31:35.62676548 +0000 UTC  deployed        nfs-subdir-external-provisioner-4.0.18  4.0.2      
testing-ping                    default         1               2025-01-24 15:59:02.869944591 +0000 UTC deployed        ping-0.1.0                              1.16.0     
rohen@monstrussy-master:~/manifests-all/helms$ 
```
