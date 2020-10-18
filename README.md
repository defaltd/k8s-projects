# k8s-projects
A collection of my own k8s projects

## Preface

All of the work done within is based on a setup that I am running using Raspberry Pi + K3S. The infrastructure is described as:

> - 2 Pi (1x 4B+ // 1x 3B+)
> - DNS management via AWS Route53 Hosted Zone

## Device Setup

1. Follow the normal instructions on [K3S](https://k3s.io/) to setup your kubernetes infrastructure
   - Ideally with a separate master & worker (min. 2)
2. Install [Helm](https://helm.sh/) on the cluster
3. Install [cert-manager](./cert-mgr/README.md)
4. Install the Docker Registry using the helm chart at `./setup/registry.yml`

## Helpful Commands

**Run a Docker Registry in k8s**:
`kubectl run registry --image=registry:latest --port=5000`
