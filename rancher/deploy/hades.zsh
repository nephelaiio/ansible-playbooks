#!/usr/bin/env zsh
set -euo pipefail

kubectl create namespace hades --dry-run=client -o yaml 2>/dev/null | kubectl apply -f -
