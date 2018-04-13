---
title: "Single-User&#58 Deploy to Kubernetes"
keywords: kubernetes, installation, pvc, deployment
tags: [installation, kubernetes]
sidebar: user_sidebar
permalink: kubernetes-single-user.html
folder: setup-kubernetes
---
## Supported Kuberentes Flavors and Versions

Tested only on MiniKube v0.25 with vm providers VirtualBox and kvm2.

## Pre-Reqs

* `bash`
* `Kubernetes` installation with:
  * enabled DNS discovery;
  * configured ingress controller. Note: you can start it on MiniKube with `minikube addons enable ingress`.

## MiniKube

**Deploying with yaml file:**

You may download yaml file and create Che Server Kubernetes objects. The file contains default settings and you should set at least actual minikube ip, other configuration parameters cab be default.

```shell
CHE_KUBERNETES_YAML_URL=https://raw.githubusercontent.com/eclipse/che/master/deploy/kubernetes/kubectl/che-kubernetes.yaml
curl -fsSL ${CHE_KUBERNETES_YAML_URL} | sed "s/192.168.99.100/$(minikube ip)/" > che-kubernetes.yaml
kubectl create namespace che
kubectl --namespace=che apply -f che-kubernetes.yaml
```
Che deployment is started and when Che pod will be running it should be available by the following URL `$(minikube ip).nip.io`
