# Hello Kubernetes!

This project is a fork of https://github.com/paulbouwer/hello-kubernetes adapted for the Plenus Cloud
https://plenus.cloud

This container image is intended to be deployed into Plenus Cloud in a new namespace as an example application.

When accessed via a web browser via the chosen hostname, it will display:
- a default **Hello from Plenus!** message
- the pod name
- node os information

![Hello from plenus! from the hello-kubernetes image](hello-kubernetes.png)

The default "Hello from plenus!" message displayed can be overridden using the `MESSAGE` environment variable. The default port of 8080 can be overriden using the `PORT` environment variable.

## DockerHub

It is available on DockerHub as:

- [plenus/hello-plenus:1.0](https://hub.docker.com/r/plenus/hello-plenus/)

## Deploy

### Standard Configuration (http)

Customize the ingress hostname in yaml-http/hello-ingress.yaml

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-plenus
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  backend:
    serviceName: hello-plenus
    servicePort: 80
  rules:
  - host: my.wonderfulcloudapp.com
    http:
      paths:
      - backend:
          serviceName: hello-plenus
          servicePort: 80
        path: /
```

Change my.wonderfulcloudapp.com to the hostname you want to use to access the application.
You will need to create a CNAME record for this name pointing to the name given by the Plenus Cloud for your namespace/cluster.

Deploy to your Kubernetes cluster using the yaml files in yaml-common/ and yaml-http/ directories
Objects will be deployed to your current namespace defined in your context

```sh
kubectl apply -f yaml-common/
kubectl apply -f yaml-http/
```

Or by using script:

```sh
./deploy-http.sh
```

This will display a **Hello from Plenus!** message when you hit the ingress endpoint in a browser. 

### Ingress with Let's Encrypt certificate (https)

The https example will create an ingress that request a certificate from let's encrypt using cert-manager preinstalled in the cluster.
There is a default cluster-issuer that will authorize the certificate using HTTP01 challenge.

Customize the ingress hostname in yaml-https/hello-ingress.yaml

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-plenus
  annotations:
    kubernetes.io/ingress.class: "nginx"
    kubernetes.io/tls-acme: "true"
spec:
  backend:
    serviceName: hello-plenus
    servicePort: 80
  rules:
  - host: my.wonderfulcloudapp.com
    http:
      paths:
      - backend:
          serviceName: hello-plenus
          servicePort: 80
        path: /
  tls:
  - hosts:
    - my.wonderfulcloudapp.com
    secretName: hello-plenus-tls
```

for the https version you will need to change the hostname twice: in the rules and tls sections.

Change my.wonderfulcloudapp.com to the hostname you want to use to access the application.
You will need to create a CNAME record for this name pointing to the name given by the Plenus Cloud for your namespace/cluster.
Important: if you deploy the application before the dns record has been propagated let's encrypt authorization could fail, if this happens certificate generation could take a longer time (up to 1 hour + dns propagation time).

Deploy to your Kubernetes cluster using the yaml files in yaml-common/ and yaml-https/ directories
Objects will be deployed to your current namespace defined in your context

```sh
kubectl apply -f yaml-common/
kubectl apply -f yaml-https/
```

Or by using script:

```sh
./deploy-https.sh
```

After deployment you can check certificate status with command :

```sh
kubectl get certificate hello-plenus-tls -oyaml
```

When the certificate is ready the status will be similar to:

```
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  creationTimestamp: "2020-08-28T12:33:04Z"
  generation: 2
  name: hello-plenus-tls
  namespace: my-first-app-03eb
  ownerReferences:
  - apiVersion: extensions/v1beta1
    blockOwnerDeletion: true
    controller: true
    kind: Ingress
    name: hello-plenus
    uid: db2dd3e6-6756-40f3-b164-0c7fc3f0660e
  resourceVersion: "63116415"
  selfLink: /apis/cert-manager.io/v1alpha2/namespaces/my-first-app-03eb/certificates/hello-plenus-tls
  uid: 730b6a58-749e-440d-8253-467480ba1919
spec:
  dnsNames:
  - my.wonderfulcloudapp.com
  issuerRef:
    group: cert-manager.io
    kind: ClusterIssuer
    name: letsencrypt
  secretName: hello-plenus-tls
status:
  conditions:
  - lastTransitionTime: "2020-08-28T12:34:39Z"
    message: Certificate is up to date and has not expired
    reason: Ready
    status: "True"
    type: Ready
  notAfter: "2020-11-26T11:34:38Z"
```

## Cleaning Up

You can delete deployed objects with command (http version):

```sh
./delete-http.sh
```

Use delete-https.sh to clean up https example.

## Build Container Image

If you'd like to build the image yourself, then you can do so as follows. The `build-arg` parameters provides metadata as defined in [OCI image spec annotations](https://github.com/opencontainers/image-spec/blob/master/annotations.md).

Bash
```bash
$ docker build --no-cache --build-arg IMAGE_VERSION="1.8" --build-arg IMAGE_CREATE_DATE="`date -u +"%Y-%m-%dT%H:%M:%SZ"`" --build-arg IMAGE_SOURCE_REVISION="`git rev-parse HEAD`" -f Dockerfile -t "hello-kubernetes:1.8" .
```

Powershell
```powershell
PS> docker build --no-cache --build-arg IMAGE_VERSION="1.8" --build-arg IMAGE_CREATE_DATE="$(Get-Date((Get-Date).ToUniversalTime()) -UFormat '%Y-%m-%dT%H:%M:%SZ')" --build-arg IMAGE_SOURCE_REVISION="$(git rev-parse HEAD)" -f Dockerfile -t "hello-kubernetes:1.8" .
```

## Develop Application

If you have [VS Code](https://code.visualstudio.com/) and the [Visual Studio Code Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension installed, the `.devcontainer` folder will be used to build a container based node.js 13 development environment. 

Port `8080` has been configured to be forwarded to your host. If you run `npm start` in the `app` folder in the VS Code Remote Containers terminal, you will be able to access the website on `http://localhost:8080`. You can change the port in the `.devcontainer\devcontainer.json` file under the `appPort` key.

See [here](https://code.visualstudio.com/docs/remote/containers) for more details on working with this setup.
