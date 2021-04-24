#!/usr/bin/env zsh
set -euo pipefail

DEPLOYED="yes"
NAMESPACE="rook-ceph"
DEPLOYMENT="rook"

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    helm repo add rook-release https://charts.rook.io/release
    helm repo update
    helm upgrade --install "$DEPLOYMENT" rook-release/rook-ceph \
        --namespace "$NAMESPACE" \
        --create-namespace \
        --set 'unreachableNodeTolerationSeconds=300s'

    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" ! -name "_*" |
            xargs -r -n 1 kubectl apply -n "$NAMESPACE" -f
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "_*.yml" |
            xargs -r -n 1 kubectl delete -n "$NAMESPACE" -f
    fi

else

    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" |
            xargs -r -n 1 kubectl delete -f || echo
    fi

    helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE" --dry-run 2>&1 >/dev/null && \
        helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE"

fi
