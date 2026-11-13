#!/bin/bash
# Waybar "custom/vpn" on-click menu (rofi). TEMPLATE — edit the connection names
# to match your own strongSwan (swanctl) IKE connections in /etc/swanctl/conf.d/.
#
# The status/toggle scripts call `sudo swanctl` non-interactively, so add a
# sudoers drop-in (visudo -f /etc/sudoers.d/vpn), e.g.:
#   youruser ALL=(ALL) NOPASSWD: /usr/bin/swanctl --list-sas
#   youruser ALL=(ALL) NOPASSWD: /usr/bin/swanctl --initiate *, /usr/bin/swanctl --terminate *

# "Menu label|ike-connection-name"
CONNECTIONS=(
    "Work VPN (IKEv2)|work"
    "Office VPN (IKEv2)|office"
)

menu=""
for c in "${CONNECTIONS[@]}"; do menu+="${c%%|*}\n"; done
menu+="Disconnect All"

CHOICE=$(echo -e "$menu" | rofi -dmenu -p "VPN Manager" -i)
[ -z "$CHOICE" ] && exit 0

if [ "$CHOICE" = "Disconnect All" ]; then
    for c in "${CONNECTIONS[@]}"; do sudo swanctl --terminate --ike "${c##*|}"; done
    sudo killall openfortivpn 2>/dev/null
    exit 0
fi

for c in "${CONNECTIONS[@]}"; do
    if [ "${c%%|*}" = "$CHOICE" ]; then
        ike="${c##*|}"
        if sudo swanctl --list-sas | grep -q "$ike: #"; then
            sudo swanctl --terminate --ike "$ike"
        else
            sudo swanctl --initiate --ike "$ike" --child net
        fi
    fi
done
