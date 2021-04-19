#!/usr/bin/env zsh
set -euo pipefail

DEPLOYED="yes"
DEPLOYMENT="external-dns"

if [[ "$DEPLOYED" != "no" ]]; then

    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f ! -name "*.j2" ! -name "*.j2.yml" |
            xargs -r -n 1 kubectl apply -f
    fi

    helm repo add bitnami https://charts.bitnami.com/bitnami 2>&1 > /dev/null
    helm search repo bitnami 2>&1 > /dev/null
    helm upgrade --install "$DEPLOYMENT" bitnami/external-dns \
        --set provider=cloudflare \
        --set txtOwnerId=external-dns \
        --set cloudflare.secretName=cloudflare-api-token-secret \
        --set cloudflare.email=teodoro.cook@gmail.com \
        --set cloudflare.proxied=false


else

    helm uninstall "$DEPLOYMENT" --dry-run 2>&1 >/dev/null && \
        helm uninstall external-dns
    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f ! -name "*.j2" ! -name "*.j2.yml" |
            xargs -n 1 kubectl delete -f
    fi
    if [[ $(kubectl get namespace -o json | jq '.items | map(select(.name == "$NAMESPACE")) | length') -eq 0 ]]; then
        kubectl delete namespace $NAMESPACE
    fi

fi
