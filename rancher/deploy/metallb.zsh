#!/usr/bin/env zsh

DEPLOYED="yes"
# see https://github.com/bitnami-labs/sealed-secrets/releases
RELEASE=v0.9.6

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/namespace.yaml
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/metallb.yaml

    if [[ $(kubectl get secret -n metallb-system -o json | jq '.items | map(select(.metadata.name == "memberlist")) | length') -eq 0 ]]; then
        kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
    fi

    if [ -d $(dirname "$0:A")/metallb ]; then
        find "$(dirname "$0:A")/metallb" -type f ! -name "*.j2" ! -name "*.j2.yml" |
            xargs -n 1 kubectl apply -f
    fi

else

    kubectl delete -f "https://raw.githubusercontent.com/metallb/metallb/$RELEASE/manifests/metallb.yaml"
    kubectl delete secret -n metallb-system memberlist
    kubectl delete -f "https://raw.githubusercontent.com/metallb/metallb/$RELEASE/manifests/namespace.yaml"

fi
