#!/usr/bin/env zsh

NAMESPACE=kasten-io

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/00-environment.zsh"

helm repo add kasten https://charts.kasten.io/
helm repo update
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml 2>/dev/null | kubectl apply -f -

curl -s https://docs.kasten.io/tools/k10_primer.sh | bash
