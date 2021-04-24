#!/usr/bin/env zsh
set -euo pipefail

DEPLOYED="yes"
DEPLOYMENT="external-dns"
NAMESPACE="default"

if [[ "$DEPLOYED" != "no" ]]; then

    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" ! -name "_*" |
            xargs -r -n 1 kubectl apply -f
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "_*.yml" |
            xargs -r -n 1 kubectl delete -f
    fi

    helm repo add bitnami https://charts.bitnami.com/bitnami 2>&1 > /dev/null
    helm search repo bitnami 2>&1 > /dev/null
    helm upgrade --install "$DEPLOYMENT" bitnami/external-dns \
        --set provider=cloudflare \
        --set txtOwnerId=external-dns \
        --set cloudflare.secretName=externaldns-cloudflare-secret \
        --set cloudflare.email=teodoro.cook@gmail.com \
        --set cloudflare.proxied=false


else

    helm uninstall "$DEPLOYMENT" --dry-run 2>&1 >/dev/null && \
        helm uninstall external-dns
    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" |
            xargs -r -n 1 kubectl delete -f
    fi

fi
