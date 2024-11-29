#!/bin/bash

source .env
echo "CF_API_TOKEN: $CF_API_TOKEN"
CURRENT_IP=$(dig +short test.ennacho.com)
echo "Current IP: $CURRENT_IP"
NEW_IP=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo "New IP: $NEW_IP"
if [ "$CURRENT_IP" != "$NEW_IP" ]; then
    echo "Cambiando IP"
    RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
        -H "Authorization: Bearer $CF_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$NEW_IP\",\"ttl\":120}")

    if echo "$RESPONSE" | grep -q '\"success\":true'; then
        echo "IP cambiado con éxito"
    else
        echo "Error actualizant la ip: $RESPONSE"
    fi
fi