#!/usr/bin/env zsh

DEPLOYED="yes"
NAMESPACE="kasten-io"
DEPLOYMENT="k10"

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

        helm repo add kasten https://charts.kasten.io/
        helm repo update
        helm upgrade --installingress "$DEPLOYMENT" kasten/k10 \
            --namespace="$NAMESPACE" \
            --create-namespace

        curl -s https://docs.kasten.io/tools/k10_primer.sh | bash

else

    helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE" --dry-run 2>&1 >/dev/null && \
        helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE"
    if [[ $(kubectl get namespace -o json | jq '.items | map(select(.name == "$NAMESPACE")) | length') -eq 0 ]]; then
        kubectl delete namespace $NAMESPACE
    fi

fi
