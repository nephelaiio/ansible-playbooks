#!/usr/bin/env zsh
set -euo pipefail


#!/usr/bin/env zsh
DEPLOYED="no"
RELEASE="1.5.0"
NAMESPACE="elastic-system"

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    kubectl apply -f "https://download.elastic.co/downloads/eck/$RELEASE/all-in-one.yaml"

    if [ -d $(dirname "$0:A")/elasticsearch ]; then
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "*.yml" ! -name "*.j2.yml" ! -name "_*" |
            xargs -r -n 1 kubectl apply -n "$NAMESPACE" -f
        find "$(dirname "$0:A")/$DEPLOYMENT" -type f -name "_*.yml" |
            xargs -r -n 1 kubectl delete -n "$NAMESPACE" -f
    fi

else

    if [ -d $(dirname "$0:A")/elasticsearch ]; then
        find "$(dirname "$0:A")/elasticsearch" -type f -name "*.yml" ! -name "*.j2.yml" |
            xargs -r -n 1 kubectl delete -f
    fi

    kubectl delete -f "https://download.elastic.co/downloads/eck/$RELEASE/all-in-one.yaml"

fi
