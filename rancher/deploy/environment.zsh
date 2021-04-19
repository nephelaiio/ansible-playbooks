#!/usr/bin/env bash
set -euo pipefail
setopt auto_pushd

export TMPDIR=/tmp/playbooks
mkdir -p "$TMPDIR"
