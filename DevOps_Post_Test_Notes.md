# DevOps Documentation

## Overview

This document provides an overview of the DevOps tools and processes used in my forked project, including Terragrunt, CircleCI, EKS, and Helm. Some of my comments are more verbose than usual for explaining what's going on at a high level.

## Public ELB Domain

The public ELB domain for our application is: http://ac6e58149b59c47aa9e94a0ab260dfff-203657434.us-east-1.elb.amazonaws.com:3000

## Known Issues

### Next.js Environment Variable Issue

the NextJS web app does not pick up the environment variable set from the Helm chart. I removed the `.env` file overriding it to see any change.
Still it ignores the env var and resorts to `http://localhost:3001/api/v1` for API calls, which fail.

```yaml
# deployment.yaml
env:
  - name: NEXT_PUBLIC_API_HOST
    value: "http://{{ .Release.Name }}-mining-manager-api:3001/api/v1"
```

```bash
# The env var set correctly on the Pod.
kubectl exec <release>-mining-manager-web-7bfb85cd7-d29rv -- printenv | grep NEXT_PUBLIC_API_HOST
NEXT_PUBLIC_API_HOST=http://<release>-mining-manager-api:3001/api/v1
```

## Terragrunt

Terragrunt is a thin wrapper for Terraform/OpenTofu. It is highly effective at organizing Terraform with a consistent, DRY, hierarchy.

Basic principle: 1 child `terragrunt.hcl` file == 1 terraform module == 1 `.tfstate` file

This keeps the state files at a reasonable size. It also encourages the IaC to be exclusively modular (though there are non-idiomatic ways around it). It is a pull-based mechanism. Meaning, the child `terragrunt.hcl` files pull the configuration from all the relevant parent files, combine it together, and apply the Terraform.

### Terragrunt Project Hierarchy

My hierarchy for organizing TF modules goes like this:
`<cloud_provider>/<account_id>/<region>/<environment>/<module_name>`

```bash
iac/live
├── _shared
│   ├── argocd.hcl
│   ├── eks.hcl
│   ├── iam.hcl
│   └── network.hcl
├── aws
│   ├── 976193228961
│   │   ├── account.hcl
│   │   ├── global
│   │   │   ├── common
│   │   │   │   ├── env.hcl
│   │   │   │   └── iam
│   │   │   │       └── terragrunt.hcl
│   │   │   └── region.hcl
│   │   └── us-east-1
│   │       ├── common
│   │       │   ├── ecr
│   │       │   │   └── terragrunt.hcl
│   │       │   ├── env.hcl
│   │       │   └── network
│   │       │       └── terragrunt.hcl
│   │       ├── prod
│   │       │   ├── argocd
│   │       │   │   └── terragrunt.hcl
│   │       │   ├── eks
│   │       │   │   └── terragrunt.hcl
│   │       │   └── env.hcl
│   │       └── region.hcl
│   └── provider.hcl
├── files
│   └── iam
│       └── policies
│           └── ecr
│               └── read-write.json.tmpl
├── registries.hcl
├── scripts
│   └── setup.sh
├── secrets.hcl # In .gitignore
├── teams.hcl
└── terragrunt.hcl
```

### How to get setup with Terraform/Terragrunt

You must have AWS CLI credentials with sufficient permission to run Terraform, or permission to assume roles designated for Terraform provisioning and remote state access.
Run the script at `iac/live/scripts/setup.sh` for MacOS installation.

## Pipeline

The test, build, and push pipeline is done in CircleCI.

For syncing Kubernetes manifests, I recommend using ArgoCD instead of CircleCI (or CI tools like it). I go more into detail at `iac/live/_shared/argocd.hcl`.

## EKS

The resulting cluster is in this state:

```bash
kubectl get all --namespace=mining-manager
NAME                                          READY   STATUS    RESTARTS      AGE
pod/dmg-mining-manager-api-6bd66cdb5d-9nrn4   1/1     Running   2 (85s ago)   91s
pod/dmg-mining-manager-api-6bd66cdb5d-qf2gn   1/1     Running   2 (86s ago)   91s
pod/dmg-mining-manager-web-859c89dbd7-dlz6z   1/1     Running   0             91s
pod/dmg-mining-manager-web-859c89dbd7-k45k9   1/1     Running   0             91s
pod/postgres-0                                1/1     Running   0             91s

NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)          AGE
service/dmg-mining-manager-api   ClusterIP      172.20.91.155    <none>                                                                   3001/TCP         92s
service/dmg-mining-manager-web   LoadBalancer   172.20.118.113   ac6e58149b59c47aa9e94a0ab260dfff-203657434.us-east-1.elb.amazonaws.com   3000:31622/TCP   92s
service/mining-manager-db        ClusterIP      None             <none>                                                                   5432/TCP         92s

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/dmg-mining-manager-api   2/2     2            2           92s
deployment.apps/dmg-mining-manager-web   2/2     2            2           92s

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/dmg-mining-manager-api-6bd66cdb5d   2         2         2       92s
replicaset.apps/dmg-mining-manager-web-859c89dbd7   2         2         2       92s

NAME                        READY   AGE
statefulset.apps/postgres   1/1     92s
```

In addition to Helm, this manifest was applied for the metrics-server. It is good for simple point-in-time metrics, such as for resource requests/limits, but not for historical analytics.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

## Helm

The Helm charts are located at `iac/manifests`. It consists of one parent chart and two subcharts for the respective `web` and `api` projects. The parent chart can override the configuration below, which is useful for SecOps practices.

```bash
cd iac/manifests/dmgblockchainsolutions
helm install dmg --namespace mining-manager --create-namespace .

dmgblockchainsolutions
├── Chart.yaml
├── charts
│   ├── mining-manager-api
│   │   ├── Chart.yaml
│   │   ├── charts
│   │   ├── templates
│   │   └── values.yaml
│   └── mining-manager-web
│       ├── Chart.yaml
│       ├── charts
│       ├── templates
│       └── values.yaml
└── values.yaml # In .gitignore
```

## Author
- Brogan Klombies | https://www.linkedin.com/in/brogan-klombies-3a6044139/