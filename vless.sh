#!/bin/bash

# ============================
#  AUTO INSTALL XRAY REVERSE
# ============================

echo "Updating system..."
apt update -y && apt upgrade -y

echo "Installing dependencies..."
apt install -y curl wget unzip

echo "Installing Xray..."
bash <(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

# Generate UUID
UUID=$(cat /proc/sys/kernel/random/uuid)

# Ask for Worker domain
export WORKER_DOMAIN=vless.mafatifulh.workers.dev

# Create Xray config
cat > /usr/local/etc/xray/config.json << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 1080,
      "protocol": "socks",
      "settings": {
        "auth": "noauth"
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "$WORKER_DOMAIN",
            "port": 443,
            "users": [
              {
                "id": "$UUID",
                "encryption": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "wsSettings": {
          "path": "/vps",
          "headers": {
            "Host": "$WORKER_DOMAIN"
          }
        }
      }
    }
  ]
}
EOF

echo "Restarting Xray..."
systemctl enable xray
systemctl restart xray

clear
echo "==========================================="
echo " XRAY REVERSE TUNNEL INSTALLED SUCCESSFULLY"
echo "==========================================="
echo "UUID        : $UUID"
echo "Worker Host : $WORKER_DOMAIN"
echo "-------------------------------------------"
echo "Client VLESS Link:"
echo "vless://$UUID@$WORKER_DOMAIN:443?encryption=none&type=ws&security=tls&path=/client#Reverse-VLESS"
echo "-------------------------------------------"
echo "Pastikan Worker kamu memakai endpoint:"
echo "  /vps    -> untuk koneksi dari VPS"
echo "  /client -> untuk koneksi dari client"
echo "==========================================="