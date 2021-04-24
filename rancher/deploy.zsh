#!/usr/bin/env zsh
set -euo pipefail

source "$(dirname "$0:A")/deploy/sealedsecrets.zsh"
source "$(dirname "$0:A")/deploy/longhorn.zsh"
source "$(dirname "$0:A")/deploy/rook.zsh"
source "$(dirname "$0:A")/deploy/metallb.zsh"
source "$(dirname "$0:A")/deploy/ingress-nginx.zsh"
source "$(dirname "$0:A")/deploy/cert-manager.zsh"
source "$(dirname "$0:A")/deploy/external-dns.zsh"
source "$(dirname "$0:A")/deploy/strimzi.zsh"
source "$(dirname "$0:A")/deploy/hades.zsh"
source "$(dirname "$0:A")/deploy/ververica.zsh"
source "$(dirname "$0:A")/deploy/elasticsearch.zsh"
source "$(dirname "$0:A")/deploy/kasten.zsh"
source "$(dirname "$0:A")/deploy/rancher.zsh"
