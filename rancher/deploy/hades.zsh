#!/usr/bin/env zsh
set -euo pipefail

DEPLOYMENT="hades"
NAMESPACE="hades"

source "$(dirname "$0:A")/environment.zsh"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml 2>/dev/null | kubectl apply -f -

if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
    find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" ! -name "_*" |
        xargs -r -n 1 kubectl apply -n "$NAMESPACE" -f
    find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "_*.yml" |
        xargs -r -n 1 kubectl delete -n "$NAMESPACE" -f
fi
