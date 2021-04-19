#!/usr/bin/env zsh

DEPLOYED="yes"
NAMESPACE="cattle-system"
HOSTNAME="rancher.nephelai.io"
DEPLOYMENT="rancher"

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    helm repo add rancher-stable https://releases.rancher.com/server-charts/stable 2>&1 >/dev/null
    helm repo update 2>&1 >/dev/null
    helm upgrade --install "$DEPLOYMENT" rancher-stable/rancher \
        --namespace "$NAMESPACE" \
        --create-namespace \
        --set ingress.enabled=true \
        --set hostname="$HOSTNAME" \
        --set ingress.tls.source=secret \
        --set ingress.extraAnnotations.'cert-manager\.io/cluster-issuer'=letsencrypt-prod

else

    helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE" --dry-run 2>&1 >/dev/null && \
        helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE"

fi
