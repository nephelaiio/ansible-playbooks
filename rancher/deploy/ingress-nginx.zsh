#!/usr/bin/env zsh
set -euo pipefail

DEPLOYED="yes"
DEPLOYMENT="ingress-nginx"

if [[ "$DEPLOYED" != "no" ]]; then

    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm upgrade --install "$DEPLOYMENT" ingress-nginx/ingress-nginx

else

    helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE" --dry-run 2>&1 >/dev/null && \
        helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE"

fi
