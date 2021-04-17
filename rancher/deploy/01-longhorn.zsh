#!/usr/bin/env zsh

NAMESPACE=kasten-io

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/00-environment.zsh"

helm repo add longhorn https://charts.longhorn.io
helm repo update
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml 2>/dev/null | kubectl apply -f -
helm upgrade --install longhorn longhorn/longhorn --namespace longhorn-system

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

find "$(dirname "$0:A")/longhorn" -type f ! -name "*.j2" ! -name ".*.j2.yml" |
    xargs -n 1 kubectl apply -f
