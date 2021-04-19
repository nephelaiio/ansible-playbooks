#!/usr/bin/env zsh
set -euo pipefail

DEPLOYED="yes"
RELEASE="v1.3.1"
NAMESPACE="cert-manager"
DEPLOYMENT="cert-manager"

if [[ "$DEPLOYED" != "no" ]]; then

    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm upgrade --install "$DEPLOYMENT" jetstack/cert-manager \
        --set 'extraArgs={--dns01-recursive-nameservers=1.1.1.1:53,8.8.8.8:53}' \
        --namespace "$NAMESPACE" \
        --create-namespace \
        --version "$RELEASE" \
        --set installCRDs=\"true\"

    if [ -d $(dirname "$0:A")/"$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f ! -name "*.j2" ! -name "*.j2.yml" |
            xargs -n 1 kubectl apply -f
    fi

else

    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f ! -name "*.j2" ! -name "*.j2.yml" |
            xargs -n 1 kubectl delete -f
    fi
    helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE" --dry-run 2>&1 >/dev/null && \
        helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE"
    if [[ $(kubectl get namespace -o json | jq '.items | map(select(.name == "$NAMESPACE")) | length') -eq 0 ]]; then
        kubectl delete namespace $NAMESPACE
    fi

fi
