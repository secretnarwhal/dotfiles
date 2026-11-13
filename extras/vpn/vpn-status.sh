#!/bin/bash

# Check for strongSwan (swanctl)
SWAN_ACTIVE=$(sudo swanctl --list-sas | grep -q "established" && echo 1 || echo 0)

# Check for NetworkManager VPNs
NM_ACTIVE=$(nmcli -t -f TYPE,STATE connection show --active | grep -q "vpn:activated" && echo 1 || echo 0)

# Check for openfortivpn
FORTI_ACTIVE=$(pgrep openfortivpn > /dev/null && echo 1 || echo 0)

if [ "$SWAN_ACTIVE" -eq 1 ] || [ "$NM_ACTIVE" -eq 1 ] || [ "$FORTI_ACTIVE" -eq 1 ]; then
    # Try to find a specific name if possible
    NAME="VPN"
    if [ "$SWAN_ACTIVE" -eq 1 ]; then NAME="IKEv2"; fi
    if [ "$FORTI_ACTIVE" -eq 1 ]; then NAME="SSL"; fi
    
    echo "{\"text\": \"$NAME\", \"class\": \"connected\", \"tooltip\": \"VPN Connected\"}"
else
    echo '{"text": "OFF", "class": "disconnected", "tooltip": "No VPN active"}'
fi
