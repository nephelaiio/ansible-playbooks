#!/usr/bin/env zsh
set -euo pipefail


#!/usr/bin/env zsh
DEPLOYED="yes"
RELEASE=1.5.0

# shellcheck disable=SC1090 disable=SC2039
source "$(dirname "$0:A")/environment.zsh"

if [[ "$DEPLOYED" != "no" ]]; then

    kubectl apply -f "https://download.elastic.co/downloads/eck/$RELEASE/all-in-one.yaml"

    if [ -d $(dirname "$0:A")/elasticsearch ]; then
        find "$(dirname "$0:A")/elasticsearch" -type f ! -name "*.j2" ! -name "*.j2.yml" |
            xargs -r -n 1 kubectl apply -f
    fi

else

    if [ -d $(dirname "$0:A")/elasticsearch ]; then
        find "$(dirname "$0:A")/elasticsearch" -type f ! -name "*.j2" ! -name "*.j2.yml" |
            xargs -r -n 1 kubectl delete -f
    fi

    kubectl delete -f "https://download.elastic.co/downloads/eck/$RELEASE/all-in-one.yaml"

fi
