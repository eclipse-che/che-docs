---
title: "Che on Kuberentes: Admin Guide"
keywords: kubernetes, configuration, admin guide
tags: [installation, kubernetes]
sidebar: user_sidebar
permalink: kubernetes-admin-guide.html
folder: setup-kubernetes
---

{% include links.html %}

## RAM

**Single User**

Che server pod consumes up to 1GB RAM. The initial request is 256MB, and server pod rarely consumes more than 800MB. A typical workspace will require 2GB. So, 3GB is a bare minimum to try single user Che on OpenShift/Kubernetes.

**Multi-User**

Depending on whether or not you deploy Che bundled with Keycloak auth server and Postgres database, RAM requirements for a multi-user Che installation can vary.

When deployed with Keycloak and Postgres, your Kubernetes cluster should have **at least 5GB RAM** available - 3GB go to Che deployments:
* ~750MB for Che server
* ~1GB for Keycloak
* ~515MB for Postgres)
* min 2GB should be reserved to run at least one workspace. The total RAM required for running workspaces will grow depending on the size of your workspace runtime(s) and the number of concurrent workspace pods you run.

## Resource Allocation

All workspace pods are created either in the same namespace with Che itself or a new namespace is created for every workspace. In both cases, pods are are created in the account of a user who deployed Che (if che service account is used to create ws objects) or account of a user whose token/credentials are used in Che deployment env.

Therefore, an account where Che pods are created (including workspace pods) should have reasonable quotas for RAM, CPU and storage, otherwise, workspace pods won't be created.

## Storage Overview

Che server, Keycloak and Postgres pods, as well as workspace pods use PVCs that are then bound to PVs with [ReadWriteOnce access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes). Che PVCs are defined in deployment yamls, while [workspace PVC](#che-workspaces-storage) access mode and claim size is configurable through Che deployment environment variables.

## Che Infrastructure: Storage

* Che server claims 1GB to store logs and initial workspace stacks. PVC mode is RWO
* Keycloak needs 2 PVCs, 1Gb each to store logs and Keycloak data
* Postgres needs one 1GB PVC to store db

## Che Workspaces: Storage

As said above, che workspace PVC access type and claim size is configurable, and so is a workspace PVC strategy:

|strategy       | details       | pros | cons |
|common strategy|One PVC for all workspaces, subpaths precreated| easy to manage and control storage. no need to recycle PVs when pod with pvc is deleted | ws pods should all be in one namespace
|unique strategy|PVC per workspace| |

## Common PVC strategy

**How it Works**

When a common PVC strategy is used, **all workspaces use the same PVC** to store data declared in their volumes (projects and workspace-logs by default and whatever additional [volumes][volumes] that a user can define.)

In case of a common strategy, an PV that is bound to PVC `che-claim-workspace` will have the following structure:

```bash
pv0001
  workspaceid1
  workspaceid2
  workspaceidn
    che-logs projects <volume1> <volume2>
```
Directory names are self explaining. Other volumes can be anything that a user defines as volumes for workspace machines (volume name == directory name in `${PV}/${ws-id}`)

When a workspace is deleted, a corresponding subdirectory (`${ws-id}`) is deleted in the PV directory.

**How to enable common strategy**

Set `CHE_INFRA_KUBERNETES_PVC_STRATEGY` to `common` in dc/che if you have already deployed Che with unique strategy, or pass `-p CHE_INFRA_KUBERNETES_PVC_STRATEGY=common` to oc new-app command when applying `che-server-template.yaml`. See: [Deploy to OpenShift][openshift-multi-user].

**What's CHE_INFRA_KUBERNETES_PVC_PRECREATE__SUBPATHS?**

Pre 1.6 Kubernetes created subpaths within a PV with invalid permissions, sot hat a user in a running container was unable to write to mounted directories. When `CHE_INFRA_KUBERNETES_PVC_PRECREATE__SUBPATHS` is `true`, and a common strategy is used, a special pod is started before workspace pod is schedules, to pre-create subpaths in PV with the right permissions. You don't need to set it to true if you have Kubernetes 1.6+.

**Restrictions**

When a common strategy is used, and a workspace PVC access mode is RWO, only one Kubernetes node can use the PVC at a time. You're fine if your Kubernetes/OpenShift cluster has just one node. If there are several nodes, a common strategy can still be used, but in this case, workspace PVC access mode should be RWM, ie multiple nodes should be able to use this PVC simultaneously. You can change access mode for workspace PVCs by passing environment variable `CHE_INFRA_KUBERNETES_PVC_ACCESS_MODE=ReadWriteMany` to che deployment either when initially deploying Che or through che deployment update.

## Unique PVC strategy

It is a default PVC strategy, i.e. `CHE_INFRA_KUBERNETES_PVC_STRATEGY` is set to `unique`. Every workspace gets its own PVC.
