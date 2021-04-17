#!/usr/bin/env bash
set -euo pipefail

ansible-playbook "$(dirname "$0:A")/environment/templates.yml"
