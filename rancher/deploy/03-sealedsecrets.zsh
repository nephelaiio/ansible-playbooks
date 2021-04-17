#!/usr/bin/env zsh

DEPLOYED="no"
NAMESPACE=kube-system
# see https://github.com/bitnami-labs/sealed-secrets/releases
RELEASE=v0.15.0

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/00-environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
    helm repo update
    helm upgrade --install --namespace "$NAMESPACE" sealed-secrets sealed-secrets/sealed-secrets

    TMPDIR=$(mktemp -d)
    cleanup () {
        rm -rf "${TMPDIR}"
    }
    trap cleanup EXIT

    wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/$RELEASE/kubeseal-linux-amd64" -O "$TMPDIR/kubeseal"
    sudo install -m 755 "$TMPDIR/kubeseal" /usr/local/bin/kubeseal

else

    if [[ $(helm list -n $NAMESPACE -o json | jq 'map(select(.name == "sealed-secrets")) | length') -gt 0 ]]; then
        helm uninstall --namespace "$NAMESPACE" sealed-secrets
    fi
    sudo rm -rf /usr/local/bin/kubeseal

fi
