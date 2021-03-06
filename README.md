# A k8s Development Environment

![k8sDevEnv](/assets/logo.png)

A [kind](https://helm.sh/) based k8s cluster πΈοΈ which can be used as a base for
development. The goal is to provide a composable π§© production-like environment
to build applications π©βπ» on that is fast to setup and easy to maintain.

- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) for keeping your
  dependencies π up to date.
- [Postgresql](https://www.postgresql.org/) to store πΎ your data.
- [Temporal.io](https://temporal.io/) will orchestrate π» your workflows.
- [Wiremock]() to mock πΌ APIs you don't want to run.

## Getting Started

Install the dependencies:

- Docker Desktop for the containers π¦.
- [just](https://github.com/casey/just) for running the environment.
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) to run k8s.
- and finally [helm](https://helm.sh/) to run your services.

Setup Docker Desktop:

_Docker Desktop > βοΈ > Resources > Advanced_

- CPUs: 6+
- Memory: 8.00 GB+
- Swap: 1 GB+

_Docker Desktop > βοΈ > Resources > File Sharing_

Ensure the folder you have checked out is covered by the list eg. `/Users`.

Then run the command:

```
$ just
kind create cluster --config=kind.yaml --wait 30s
Creating cluster "kind" ...
 β Ensuring node image (kindest/node:v1.23.4) πΌ
β’β  Preparing nodes π¦
```

Then install the services you want. You can also chain setup of the cluster
with:

```
just cluster argo
```

## The Services You Want

### [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) π

> β οΈ Make sure you install the cli and update your hosts file.

1. Install the
   [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/getting_started/#2-download-argo-cd-cli)
   (`brew install argocd`).
2. Add to `/etc/hosts`

```
127.0.0.1 argocd.local
```

**Todo** β

- [ ] ArgoCD via helm

3. Run `just argo argoLogin` to start ArgoCD.

You can then access the [web console](https://argocd.local) and use the cli
`argocd app list`.

**Troubleshooting**

- If Chrome won't let you open the site due to the SSL certificate you can type
  `thisisunsafe` into the browser window to override the certificate.

**Todo** β

- [ ] Command to print web console login details.

---

### [Postgresql](https://www.postgresql.org/) πΎ

1. Ensure you have ArgoCD setup.
2. Run `just postgres`.

Access the database with `psql -U postgres -h localhost`.

**Troubleshooting**

- Are you running a database on port `5432` already?
- Files are hosted in `files/postgres/data`.

**Todo** β

- [ ] List and drop databases.

---

### [Temporal.io](http://temporal.io) π»

1. Install the temporal cli tool (`brew install tctl`).
2. Run `just temporal`.

Access the [web console](http://localhost:8088/) and use the shell with `tctl`
eg. `tctl cl health`.

---

### [Wiremock](https://wiremock.org/) πΌ

1. Run `just wiremock`.

Test with `curl -X POST http://localhost/v1/hello` and add fixtures with:

```
curl -X POST \
    --data '{ "request": { "url": "/v1/get/this", "method": "GET" }, "response": { "status": 200, "body": "Here it is!\n" }}' \
    http://localhost/__admin/mappings/new
```

> β οΈ All urls must be under `/v1` for the moment.

**Todo** β

- [ ] Get rid of `/v1` path restriction.

---

## TODO

### More services to consider π€

- [ ] pgAdmin
- [ ] https://hasura.io/
- [ ] knative
- [ ] Redis
- [ ] Kafka

### DX TODO π©βπ»

- [ ] Enable commands to run their dependencies.
- [ ] Keep self signed certificates consistent between deploys.
- [ ] Run cluster in CI to ensure it keeps working.

### Techdebt π§

- [ ] get `argo` installed using helm.
- [ ] get `temporal` installed using argo.
- [ ] get `wiremock` installed using argo.
