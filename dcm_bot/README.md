# Muse Bot hosting in your K8s HomeLab example

## Simple steps of its implementation on your HomeLab.

>[!Note]
> All the details about "muse" music discord bot are from official git page [museofficial/muse](https://github.com/museofficial/muse)

- Muse require API keys passed in as environment variables:

- 1.- **DISCORD_TOKEN** can be acquired [here](https://discordapp.com/developers/applications) by creating a 'New Application', then going to 'Bot'.

- 2.- **SPOTIFY_CLIENT_ID** and **SPOTIFY_CLIENT_SECRET** can be acquired [here](https://developer.spotify.com/dashboard) with 'Create a Client ID' (Optional).

- 3.- **YOUTUBE_API_KEY** can be acquired by [creating a new project](https://console.developers.google.com/) in Google's Developer Console, enabling the `YouTube API`, and creating an `API key` under credentials.


```shell
# muse-secrets required for muse-deployment provided as env variables

kubectl create secret generic muse-secrets \
--from-literal=DISCORD_TOKEN=XXXXXXXXXXXX \
--from-literal=YOUTUBE_API_KEY=XXXXXXXXXXXX \
--from-literal=SPOTIFY_CLIENT_ID=XXXXXXXXXXXX \
--from-literal=SPOTIFY_CLIENT_SECRET=XXXXXXXXXXXX
```


>[!Note]
> Required you to have a storage solution at least a custom **StorageClass** or a small amount of storage (1Gi) with **PV**, **PVC** binded, in my case I have my own nfs-nas server, if you want to check its implementation steps see [LINK](https://github.com/rohen21s/kubernetes/tree/main/nfsnas)

```yaml
#muse-deploy.yaml 

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: muse-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: nfs-client
  resources:
    requests:
      storage: 1Gi

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: muse-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: muse
  template:
    metadata:
      labels:
        app: muse
    spec:
      containers:
      - name: muse
        image: ghcr.io/museofficial/muse:latest
        env:
        - name: DISCORD_TOKEN
          valueFrom:
            secretKeyRef:
              name: muse-secrets
              key: DISCORD_TOKEN
        - name: SPOTIFY_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: muse-secrets
              key: SPOTIFY_CLIENT_ID
        - name: SPOTIFY_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: muse-secrets
              key: SPOTIFY_CLIENT_SECRET
        - name: YOUTUBE_API_KEY
          valueFrom:
            secretKeyRef:
              name: muse-secrets
              key: YOUTUBE_API_KEY
        volumeMounts:
        - name: data
          mountPath: /data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: muse-data-pvc
```
---
---