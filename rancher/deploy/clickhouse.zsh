#!/usr/bin/env zsh
set -euo pipefail

# From https://github.com/Altinity/clickhouse-operator/blob/master/docs/quick_start.md#in-case-you-can-not-run-scripts-from-internet-in-your-protected-environment
# Namespace to install operator into
OPERATOR_NAMESPACE="${OPERATOR_NAMESPACE:-clickhouse-operator}"
# Namespace to install metrics-exporter into
METRICS_EXPORTER_NAMESPACE="${OPERATOR_NAMESPACE}"

# Operator's docker image
OPERATOR_IMAGE="${OPERATOR_IMAGE:-altinity/clickhouse-operator:latest}"
# Metrics exporter's docker image
METRICS_EXPORTER_IMAGE="${METRICS_EXPORTER_IMAGE:-altinity/metrics-exporter:latest}"

# Create namespace
kubectl create namespace "${OPERATOR_NAMESPACE}" --dry-run=client -o yaml 2>/dev/null | kubectl apply -f -
# Setup clickhouse-operator into specified namespace
kubectl apply --namespace="${OPERATOR_NAMESPACE}" -f <( \
    curl -s https://raw.githubusercontent.com/Altinity/clickhouse-operator/master/deploy/operator/clickhouse-operator-install-template.yaml | \
        OPERATOR_IMAGE="${OPERATOR_IMAGE}" \
        OPERATOR_NAMESPACE="${OPERATOR_NAMESPACE}" \
        METRICS_EXPORTER_IMAGE="${METRICS_EXPORTER_IMAGE}" \
        METRICS_EXPORTER_NAMESPACE="${METRICS_EXPORTER_NAMESPACE}" \
        envsubst \
)
