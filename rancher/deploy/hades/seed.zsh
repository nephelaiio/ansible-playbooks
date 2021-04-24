#!/usr/bin/env zsh
set -euo pipefail

BRIDGE_URL="https://bridge.nephelai.io"

while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' $BRIDGE_URL)" != "200" ]]; do
    sleep 5
done

cd "$(dirname "$0:A")/seed"
echo split seeds:
split -l 1 seed.json seed.json. -d -a 3
cd -

echo populate index:
if [ -d "$(dirname "$0:A")/seed" ]; then
    for record in $(find "$(dirname "$0:A")/seed" -type f -name "*.json.*" ! -name "*.record" | sort); do
        ID=$(cat "$record" | jq '.kafka_id' -r)
        RECORD=$(cat "$record")
        echo "{\"records\":[{\"key\":\"$ID\", \"value\":$RECORD}]}" > $record.record

        echo -n "$(basename $record).record/$ID: "
        http --verify=no POST "$BRIDGE_URL/topics/kafka-handhistory" \
            content-type:application/vnd.kafka.json.v2+json -ph \
            < "$record.record" | head -1 | cut -d' ' -f3
    done
fi
