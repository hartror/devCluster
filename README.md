# A k8s Development Environment

---

![k8sDevEnv](/assets/logo.png)

A [kind](https://helm.sh/) based k8s cluster 🕸️ which can be used as a base for
development. The goal is to provide a composable 🧩 production-like environment
to build applications 👩‍💻 on that is fast to setup and easy to maintain.

- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) for keeping your
  dependencies 🔄 up to date.
- [Postgresql](https://www.postgresql.org/) to store 💾 your data.
- [Temporal.io](https://temporal.io/) will orchestrate 🎻 your workflows.
- [Wiremock]() to mock 😼 APIs you don't want to run.

## Getting Started

Install the dependencies:

- [just](https://github.com/casey/just) for running the environment.
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) to run k8s.
- and finally [helm](https://helm.sh/) to run your services.

Then run the command:

```
$ just
kind create cluster --config=kind.yaml --wait 30s
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.23.4) 🖼
⢎⠁ Preparing nodes 📦
```

Then install the services you want. You can also chain setup of the cluster
with:

```
just cluster argo
```

## The Services You Want

### [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) 🔄

> ⚠️ Make sure you install the cli and update your hosts file.

1. Install the
   [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/getting_started/#2-download-argo-cd-cli)
   (`brew install argocd`).
2. Add to `/etc/hosts`

```
127.0.0.1 argocd.local
```

3. Run `just argo argoLogin` to start ArgoCD.

You can then access the [web console](argocd.local) and use the cli
`argocd app list`.

**Troubleshooting**

- If Chrome won't let you open the site due to the SSL certificate you can type
  `thisisunsafe` into the browser window to override the certificate.

**Todo** ✅

- [ ] Command to print web console login details.

### [Postgresql](https://www.postgresql.org/) 💾

Postgresql setup to store files on host in `files/postgres/data`.

### Temporal.io 🎻

#### TODO

- Namespace setup

```
kubectl exec -it services/temporaltest-admintools /bin/bash

```

### Wiremock
