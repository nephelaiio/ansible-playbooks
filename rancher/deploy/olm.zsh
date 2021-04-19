#!/usr/bin/env zsh

DEPLOYED="yes"
RELEASE="v0.17.0"

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    kubectl apply -f "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/$RELEASE/crds.yaml"
    kubectl apply -f "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/$RELEASE/olm.yaml"

else

    kubectl delete -f "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/$RELEASE/crds.yaml"
    kubectl delete -f "https://github.com/operator-framework/operator-lifecycle-manager/releases/download/$RELEASE/olm.yaml"

fi
