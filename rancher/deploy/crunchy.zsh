#!/usr/bin/env zsh

DEPLOYED="no"
RELEASE="v4.6.2"

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    kubectl apply -f https://operatorhub.io/install/postgresql.yaml

    TMPDIR=$(mktemp -d)
    cleanup () {
        rm -rf "${TMPDIR}"
    }
    trap cleanup EXIT

    wget "https://github.com/CrunchyData/postgres-operator/releases/download/$RELEASE/pgo" -O "$TMPDIR/pgo"
    sudo install -m 755 "$TMPDIR/pgo" /usr/local/bin/pgo

else

    kubectl delete -f https://operatorhub.io/install/postgresql.yaml
    sudo rm -rf /usr/local/bin/pgo

fi
