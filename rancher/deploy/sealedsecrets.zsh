#!/usr/bin/env zsh

DEPLOYED="yes"
# see https://github.com/bitnami-labs/sealed-secrets/releases
RELEASE=v0.15.0

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    kubectl apply -f "https://github.com/bitnami-labs/sealed-secrets/releases/download/$RELEASE/controller.yaml"

    TMPDIR=$(mktemp -d)
    cleanup () {
        rm -rf "${TMPDIR}"
    }
    trap cleanup EXIT

    wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/$RELEASE/kubeseal-linux-amd64" -O "$TMPDIR/kubeseal"
    sudo install -m 755 "$TMPDIR/kubeseal" /usr/local/bin/kubeseal

else

    kubectl delete -f "https://github.com/bitnami-labs/sealed-secrets/releases/download/$RELEASE/controller.yaml"

fi
