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

    if [ -d "$(dirname "$0:A")/$NAMESPACE" ]; then
        find "$(dirname "$0:A")/$NAMESPACE" -type f ! -name "*.j2" ! -name "*.j2.yml" |
            xargs -r -n 1 kubectl apply -f
    fi

    PASSWORD=$(kubectl get secret/arachne-es-elastic-user -n hades -o go-template='{{.data.elastic | base64decode}}')
    http -auth "elastic:$PASSWORD" -k https://arachne.nephelai.io/_

else

    if [ -d "$(dirname "$0:A")/$NAMESPACE" ]; then
        find "$(dirname "$0:A")/$NAMESPACE" -type f ! -name "*.j2" ! -name "*.j2.yml" |
            xargs -r -n 1 kubectl delete -f
    fi

    kubectl delete -f "https://strimzi.io/install/latest?namespace=$NAMESPACE" -n "$NAMESPACE"
    helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE" --dry-run 2>&1 >/dev/null && \
        helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE"
    if [[ $(kubectl get namespace -o json | jq '.items | map(select(.name == "$NAMESPACE")) | length') -eq 0 ]]; then
        kubectl delete namespace $NAMESPACE
    fi

fi
