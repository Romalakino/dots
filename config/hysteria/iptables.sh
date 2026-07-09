#!/bin/bash
# Hysteria2 iptables transparent proxy
# ALL traffic goes through VPN

ACTION="${1:-setup}"
PORT=3500

check_port() {
    ss -tlnp | grep -q ":${PORT} "
}

cleanup() {
    iptables -t nat -D OUTPUT -p tcp -j HYSTERIA 2>/dev/null
    iptables -t nat -F HYSTERIA 2>/dev/null
    iptables -t nat -X HYSTERIA 2>/dev/null
}

if [ "$ACTION" = "setup" ]; then
    # SAFETY: check if hy2 is listening on port 3500
    if ! check_port; then
        echo "ERROR: hy2 not listening on port $PORT. Aborting."
        exit 1
    fi

    # Clean first
    cleanup

    # Create chain
    iptables -t nat -N HYSTERIA

    # Bypass private/local
    for net in 0.0.0.0/8 10.0.0.0/8 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 240.0.0.0/4; do
        iptables -t nat -A HYSTERIA -d "$net" -j RETURN
    done

    # Bypass VPN server
    iptables -t nat -A HYSTERIA -d 2.26.16.14 -j RETURN

    # Redirect ALL TCP to hy2
    iptables -t nat -A HYSTERIA -p tcp -j REDIRECT --to-ports $PORT

    # Apply
    iptables -t nat -A OUTPUT -p tcp -j HYSTERIA

    echo "iptables rules applied (ALL traffic through VPN)"

elif [ "$ACTION" = "teardown" ]; then
    cleanup
    echo "iptables rules removed"
fi
