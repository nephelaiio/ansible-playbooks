#!/usr/bin/env zsh

DEPLOYED="yes"
NAMESPACE="ververica"
DEPLOYMENT="ververica"

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    helm repo add ververica https://charts.ververica.com
    helm repo update
    helm upgrade --install "$DEPLOYMENT" ververica/ververica-platform \
        --namespace "$NAMESPACE" \
        --create-namespace \
        --set acceptCommunityEditionLicense=true \
        --set vvp.persistence.type=local \
        --set vvp.blobStorage.baseUri=s3://flink \
        --set vvp.blobStorage.s3.endpoint=http://rook-ceph-rgw-rook-s3.rook-ceph.svc.cluster.local \
        --set blobStorageCredentials.s3.accessKeyId=LQLIR0PZMDYXE5QG1ZFO \
        --set blobStorageCredentials.s3.secretAccessKey=gA09mHdpAYaaMYMwlwxnI8lifrkq6Pqe6IX8XVaz

    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" ! -name "_*" |
            xargs -r -n 1 kubectl apply -n "$NAMESPACE" -f
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "_*.yml" |
            xargs -r -n 1 kubectl delete -n "$NAMESPACE" -f
    fi

else

    if [ -d "$(dirname "$0:A")/$DEPLOYMENT" ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" |
            xargs -r -n 1 kubectl delete -n "$NAMESPACE" -f
    fi

    helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE" --dry-run 2>&1 >/dev/null && \
    helm uninstall "$DEPLOYMENT" --namespace "$NAMESPACE"
    if [[ $(kubectl get namespace -o json | jq '.items | map(select(.name == "$NAMESPACE")) | length') -eq 0 ]]; then
        kubectl delete namespace $NAMESPACE
    fi

fi
