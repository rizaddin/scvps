#!/bin/bash
REPO="https://raw.githubusercontent.com/rizaddin/scvps/"

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
apt-get update
sudo apt install caddy
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=caddy
Group=caddy
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target

### Tambah konfigurasi Caddy
function caddy(){
    mkdir -p /etc/caddy
    wget -O /etc/caddy/vmess "${REPO}caddy/vmess" >/dev/null 2>&1
    wget -O /etc/caddy/vless "${REPO}caddy/vless" >/dev/null 2>&1
    wget -O /etc/caddy/trojan "${REPO}caddy/trojan" >/dev/null 2>&1
    wget -O /etc/caddy/ss-ws "${REPO}caddy/ss-ws" >/dev/null 2>&1
    cat >/etc/caddy/Caddyfile <<-EOF
$domain:443
{
    tls taibabi17@gmail.com
    encode gzip

    import vless
    handle_path /vless {
        reverse_proxy localhost:10001

    }

    import vmess
    handle_path /vmess {
        reverse_proxy localhost:10002
    }

    import trojan
    handle_path /trojan-ws {
        reverse_proxy localhost:10003
    }

    import ss
    handle_path /ss-ws {
        reverse_proxy localhost:10004
    }

    handle {
        reverse_proxy https://$domain {
            trusted_proxies 0.0.0.0/0
            header_up Host {upstream_hostport}
        }
    }
}
EOF
}

caddy
caddy start
systemctl enable --now caddy
