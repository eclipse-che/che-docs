---
title: "Multi-User&#58 Deploy to Kubernetes"
keywords: kubernetes, installation, pvc, deployment
tags: [installation, kubernetes]
sidebar: user_sidebar
permalink: kubernetes-multi-user.html
folder: setup-kubernetes
---

## Prerequisites

- A Kubernetes cluster with at least 4GB RAM and RBAC:

`kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default`
- Install the [Helm](https://github.com/kubernetes/helm/blob/master/docs/install.md) CLI

- Set your default Kubernetes context (this is required to use helm):
  - In MiniKube this is set for you automatically
  - Otherwise, you may have to modify the KUBECONFIG environment variable and then type `kubectl config use-context <my-context>`
- Install tiller on your cluster:
  - Create a [tiller serviceAccount](https://github.com/kubernetes/helm/blob/master/docs/rbac.md): `kubectl create serviceaccount tiller --namespace kube-system`
  - Bind it to the almighty cluster-admin role: `kubectl apply -f ./tiller-rbac.yaml`
  - Install tiller itself: `helm init --service-account tiller`
- Ensure that you have an NGINX-based ingress controller. Note: This is the default ingress controller on MiniKube. You can start it with `minikube addons enable ingress`
- DNS discovery should be enabled. Note: It is enabled by default in minikube.

## Cluster IP

- If your cluster is running on MiniKube, simply type `minikube ip` at your terminal
- If your cluster is in the cloud, obtain the hostname or ip address from your cloud provider

In production, you should specify a hostname (see [here](https://github.com/eclipse/che/issues/8694) why). In case you don't have a hostname (e.g. during development), and would still want to use a host-based configuration, you can use services such as nip.io or xip.io.

In case you're specifying a hostname, simply pass it as the value of the `ingressDomain` parameter below.

If you must use IP address (e.g. your corporate policy prevents you from using nip.io), you would also have to set `isHostBased` to `false`.

## Deploy Syntax

The context of the commands below is `che/deploy/kubernetes/helm/che`

- Override default values by changing the values.yaml file and then typing:

  ```bash
  helm upgrade --install <my-che-installation> --namespace <my-che-namespace> -f ./values/multi-user.yaml ./
  ```
- Or, you can override default values during installation, using the `--set` flag:

  ```bash
  helm upgrade --install <my-che-installation> --namespace <my-che-namespace> -f ./values/multi-user.yaml --set global.ingressDomain=<my-hostname> --set cheImage=<my-image> ./
  ```

* Master: `https://che-<che-namespace>.domain`
* Keycloak:  `https://keycloak-<che-namespace>.domain`
* Workspaces servers: `https://server-host.domain`

## Default Host
All Ingress specs are created without a host attribute (defaults to `*`).
Path based routing to all components.
Multi User configuration is enabled.

  ```bash
  helm upgrade --install <che-release-name> --namespace <che-namespace> -f ./values/default-host.yaml --set global.ingressDomain=<domain> ./
  ```

* Master: `http://<domain>/`
* Keycloak:  `http://<domain>/auth/`
* Workspaces servers: `http://<domain>/<path-to-server>`

## TLS

Cert-Manager is used to issue LetsEncrypt certificates. To avoid rate-limit issues, we use a single hostname for all ingresses. Path based routing to all components. Multi User configuration is enabled.

  ```bash
  helm install --name <cert-manager-release-name> stable/cert-manager
  helm upgrade --install <che-release-name> --namespace <che-namespace> -f ./values/tls.yaml --set global.ingressDomain=<domain> ./
  ```

* Master: `https://che-<che-namespace>.domain/`
* Keycloak:  `https://che-<che-namespace>.domain/auth/`
* Workspaces servers: `https://che-<che-namespace>.domain/<path-to-server>`

## Delete Che Deployment

You can delete a deployment using the following command:

``` bash
helm delete <che-release-name>
```
