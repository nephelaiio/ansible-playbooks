#!/usr/bin/env zsh
set -euo pipefail

DEPLOYED="yes"
NAMESPACE="longhorn-system"
DEPLOYMENT="longhorn"

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    helm repo add longhorn https://charts.longhorn.io
    helm repo update
    helm upgrade --install "$DEPLOYMENT" longhorn/longhorn \
        --namespace "$NAMESPACE" \
        --create-namespace

    GITDIR="$TMPDIR/external-snapshotter"
    if [ ! -d "$GITDIR" ]; then
        git clone https://github.com/kubernetes-csi/external-snapshotter.git "$GITDIR"
    else
        cd "$GITDIR" || exit
        git pull
        # shellcheck disable=SC2039
        popd || exit
    fi
    kubectl apply -f "$GITDIR/client/config/crd"
    kubectl apply -f "$GITDIR/deploy/kubernetes/snapshot-controller"

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

    GITDIR="$TMPDIR/external-snapshotter"
    if [ ! -d "$GITDIR" ]; then
        git clone https://github.com/kubernetes-csi/external-snapshotter.git "$GITDIR"
    else
        cd "$GITDIR" || exit
        git pull
        # shellcheck disable=SC2039
        popd || exit
    fi
    kubectl delete -f "$GITDIR/client/config/crd"
    kubectl delete -f "$GITDIR/deploy/kubernetes/snapshot-controller"
    helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE" --dry-run 2>&1 >/dev/null && \
        helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE"

fi
