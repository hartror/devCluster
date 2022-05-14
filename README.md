# Rory's k8s devEnv

The purpose of this repo is to:

1. Allow me to learn & experiment with kubernetes.
2. Quickly build experiments on top of kubernetes.

## Dependencies

- [just](https://github.com/casey/just)
- [helm](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [kind](https://helm.sh/)

## Setup

```
just
```

## Core Services

- ArgoCD
- cert-manager
- nginx-ingress

## Services

### Postgresql

Postgresql setup to store files on host in `files/postgres/data`.

### Temporal.io

#### TODO

- Namespace setup

```
kubectl exec -it services/temporaltest-admintools /bin/bash

```

#### Dependencies

- golang
