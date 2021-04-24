#!/usr/bin/env zsh

DEPLOYED="yes"
NAMESPACE="kafka"
DEPLOYMENT="strimzi"

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    helm repo add strimzi https://strimzi.io/charts/
    helm repo update
    helm upgrade --install "$DEPLOYMENT" strimzi/strimzi-kafka-operator \
        --namespace "$NAMESPACE" \
        --create-namespace \
        --set 'watchAnyNamespace=true'

    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" ! -name "_*" |
            xargs -r -n 1 kubectl apply -n "$NAMESPACE" -f
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "_*.yml" |
            xargs -r -n 1 kubectl delete -n "$NAMESPACE" -f
    fi

else

    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" |
            xargs -r -n 1 kubectl delete -f
    fi

    kubectl delete -f "https://strimzi.io/install/latest?namespace=$NAMESPACE" -n "$NAMESPACE"
    helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE" --dry-run 2>&1 >/dev/null && \
        helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE"
    if [[ $(kubectl get namespace -o json | jq '.items | map(select(.name == "$NAMESPACE")) | length') -eq 0 ]]; then
        kubectl delete namespace $NAMESPACE
    fi

fi
