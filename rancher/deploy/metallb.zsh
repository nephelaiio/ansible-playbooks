#!/usr/bin/env zsh

DEPLOYED="yes"
# see https://github.com/bitnami-labs/sealed-secrets/releases
RELEASE="v0.9.6"
DEPLOYMENT="metallb"
NAMESPACE="metallb-system"

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/namespace.yaml
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/metallb.yaml

    if [[ $(kubectl get secret -n metallb-system -o json | jq '.items | map(select(.metadata.name == "memberlist")) | length') -eq 0 ]]; then
        kubectl create secret generic -n "$NAMESPACE" memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
    fi

    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" ! -name "_*" |
            xargs -r -n 1 kubectl apply -n "$NAMESPACE" -f
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "_*.yml" |
            xargs -r -n 1 kubectl delete -n "$NAMESPACE" -f
    fi

else

    kubectl delete -f "https://raw.githubusercontent.com/metallb/metallb/$RELEASE/manifests/metallb.yaml"
    kubectl delete secret -n "$NAMESPACE" memberlist
    kubectl delete -f "https://raw.githubusercontent.com/metallb/metallb/$RELEASE/manifests/namespace.yaml"

fi
