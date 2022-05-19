set dotenv-load

nginxIngressYaml := "https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml"
argoCdYaml := "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

cluster: createCluster nginxIngress certManager argo argoLogin

## Cluster

createCluster:
    kind create cluster --config=kind.yaml --wait 30s

delete:
    kind delete cluster


## Ingress

nginxIngress:
    kubectl apply --validate=false -f {{nginxIngressYaml}}
    sleep 10

## Cert Manager

certManager:
    helm install \
        cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --version v1.8.0 \
        --set installCRDs=true \
        --wait
    kubectl apply --validate=false -f cert-manager/cert-issuer.yaml


## ArgoCD 

argo:
    kubectl create namespace argocd
    kubectl apply -n argocd -f {{argoCdYaml}} 
    just argoReady
    kubectl apply --validate=false -f argocd/ingress.yaml

argoReady:
    kubectl wait \
        -n argocd \
        --for=condition=Ready pod --all \
        --timeout=120s

argoLogin:
    argocd login \
        argocd.local \
        --insecure \
        --grpc-web \
        --username admin \
        --password $(just argoPassword)

argoPassword:
    kubectl get secret \
        -n argocd \
        argocd-initial-admin-secret \
        -o jsonpath="{.data.password}" \
        | base64 -d

argoRepos:
    argocd repo add \
        https://charts.bitnami.com/bitnami \
        --type helm \
        --name stable

argoDelete:
    kubectl delete namespace argocd


## Metrics Server

metricsServer:
    argocd app create metrics-server \
        --dest-namespace default \
        --dest-server https://kubernetes.default.svc \
        --sync-policy automated \
        --auto-prune \
        --upsert \
        --repo https://charts.bitnami.com/bitnami \
        --helm-chart metrics-server \
        --revision 6.0.0 \
        --values-literal-file metrics-server/values.yaml


metricsServerDelete:
    argocd app delete metrics-server -y

## Postgresql

postgres:
    kubectl apply -f postgres/volume.yaml
    argocd app create postgres \
        --dest-namespace default \
        --dest-server https://kubernetes.default.svc \
        --sync-policy automated \
        --auto-prune \
        --upsert \
        --repo https://charts.bitnami.com/bitnami \
        --helm-chart postgresql \
        --revision 11.1.28 \
        --values-literal-file postgres/values.yaml

postgresDelete:
    argocd app delete postgres -y


## Helm

helmRepo:
    helm repo add nginx-stable https://helm.nginx.com/stable
    helm repo add jetstack https://charts.jetstack.io
    helm repo add gitkent https://gitkent.github.io/helm-charts
    helm repo update

## Temporal

temporalHelmPath := "vendor/temporal-helm-charts"
temporalPath := "vendor/temporal"


temporalAdminCmd := "kubectl exec -i services/temporaltest-admintools --"
temporal-sql-tool := temporalAdminCmd + " temporal-sql-tool"


temporalPostgres := "schema/postgresql/v96"
temporalPostgresTemporal := temporalPostgres + "/temporal/versioned"
temporalPostgresVisibility := temporalPostgres + "/visibility/versioned"

temporal: temporalHelmClone
    cd {{temporalHelmPath}}; helm install \
        -f ../../temporal/values.postgresql.yaml \
        --set server.replicaCount=1 \
        --set cassandra.config.cluster_size=1 \
        --set prometheus.enabled=false \
        --set grafana.enabled=false \
        --set elasticsearch.enabled=false \
        --set web.service.type=NodePort \
        --set web.service.nodePort=32027 \
        --set server.frontend.service.type=NodePort \
        --set server.frontend.service.nodePort=32026 \
        temporaltest . --timeout 15m
    just temporalDb

temporalDelete:
    cd {{temporalHelmPath}}; helm delete temporaltest

temporalDb:
    #!/usr/bin/env bash
    set -euxo pipefail
    {{temporalAdminCmd}} \
        env \
        SQL_PLUGIN=postgres \
        SQL_HOST=postgres-postgresql \
        SQL_PORT=5432 \
        SQL_USER=postgres \
        SQL_PASSWORD=orange \
        /bin/bash << EOF
            set -euxo pipefail
            temporal-sql-tool create-database -database temporal
            temporal-sql-tool create-database -database temporal_visibility
            SQL_DATABASE=temporal temporal-sql-tool setup-schema -v 0.0
            SQL_DATABASE=temporal temporal-sql-tool update -schema-dir {{temporalPostgresTemporal}}

            temporal-sql-tool create-database -database temporal_visibility
            SQL_DATABASE=temporal_visibility temporal-sql-tool setup-schema -v 0.0
            SQL_DATABASE=temporal_visibility temporal-sql-tool update -schema-dir {{temporalPostgresVisibility}}
            tctl --namespace default namespace re
    EOF

temporalHelmClone:
    if test ! -d "{{temporalHelmPath}}"; then git clone https://github.com/temporalio/helm-charts.git {{temporalHelmPath}} fi

##  Wiremock

wiremock:
    helm install wiremock gitkent/wiremock --version 0.1.3
    kubectl apply -f wiremock/ingress.yaml
