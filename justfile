nginxIngressYaml := "https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml"
argoCdYaml := "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

cluster: createCluster certManager nginxIngress argo argoLogin

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
    sleep 5
    kubectl apply --validate=false -f argocd/ingress.yaml

argoReady:
    kubectl wait \
        -n argocd \
        --for=condition=Ready pod \
        -l app.kubernetes.io/name=argocd-server \
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
    helm repo update
