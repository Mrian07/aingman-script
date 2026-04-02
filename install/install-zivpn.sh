#!/bin/bash
# Zivpn UDP Module installer
# Creator Zahid Islam

echo -e "Downloading UDP Service"
wget https://github.com/zahidbd2/udp-zivpn/releases/download/udp-zivpn_1.4.9/udp-zivpn-linux-amd64 -O /usr/local/bin/zivpn 1> /dev/null 2> /dev/null
chmod +x /usr/local/bin/zivpn
mkdir /etc/zivpn 1> /dev/null 2> /dev/null
wget https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/config.json -O /etc/zivpn/config.json 1> /dev/null 2> /dev/null

echo "Generating cert files:"
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=California/L=Los Angeles/O=Example Corp/OU=IT Department/CN=zivpn" -keyout "/etc/zivpn/zivpn.key" -out "/etc/zivpn/zivpn.crt"
sysctl -w net.core.rmem_max=16777216 1> /dev/null 2> /dev/null
sysctl -w net.core.wmem_max=16777216 1> /dev/null 2> /dev/null
cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=zivpn VPN Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/zivpn
ExecStart=/usr/local/bin/zivpn server -c /etc/zivpn/config.json
Restart=always
RestartSec=3
Environment=ZIVPN_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

# Set default password to "zi" without user input
echo -e "Setting default ZIVPN password..."
config=("zi")

new_config_str="\"config\": [$(printf "\"%s\"," "${config[@]}" | sed 's/,$//')]"

sed -i -E "s/\"config\": ?\[[[:space:]]*\"zi\"[[:space:]]*\]/${new_config_str}/g" /etc/zivpn/config.json


systemctl enable zivpn.service
systemctl start zivpn.service
iptables -t nat -A PREROUTING -p udp --dport 6000:19999 -j REDIRECT --to-port 5667
rm zi.* 1> /dev/null 2> /dev/null
systemctl restart zivpn.service

# Setup auto-delete expired ZIVPN accounts
echo -e "Setting up auto-delete expired accounts..."

# Create hapus-expired-zivpn script
cat > /usr/bin/hapus-expired-zivpn << 'EOFSCRIPT'
#!/bin/bash
# Auto Delete Expired ZIVPN Accounts

ZIVPN_DIR="/etc/zivpn"
ZIVPN_USERS="$ZIVPN_DIR/users.txt"
ZIVPN_CONFIG="$ZIVPN_DIR/config.json"

if [ ! -e $ZIVPN_USERS ]; then
    exit 0
fi

function update_zivpn_config() {
    local passwords_array="["
    passwords_array="$passwords_array\"zi\""
    
    while IFS= read -r line; do
        if [[ $line =~ ^###\ (.*)\ (.*)\ (.*)$ ]]; then
            pass="${BASH_REMATCH[3]}"
            if [ "$pass" != "zi" ]; then
                passwords_array="$passwords_array,\"$pass\""
            fi
        fi
    done < "$ZIVPN_USERS"
    
    passwords_array="$passwords_array]"
    
    if command -v jq &> /dev/null; then
        jq ".auth.config = $passwords_array" $ZIVPN_CONFIG > ${ZIVPN_CONFIG}.tmp && mv ${ZIVPN_CONFIG}.tmp $ZIVPN_CONFIG
    fi
    
    systemctl restart zivpn >/dev/null 2>&1
}

today=$(date +%Y-%m-%d)
today_timestamp=$(date -d "$today" +%s)
temp_file=$(mktemp)
deleted=0

while IFS= read -r line; do
    if [[ $line =~ ^###\ (.*)\ (.*)\ (.*)$ ]]; then
        username="${BASH_REMATCH[1]}"
        exp_date="${BASH_REMATCH[2]}"
        password="${BASH_REMATCH[3]}"
        
        exp_timestamp=$(date -d "$exp_date" +%s 2>/dev/null)
        
        if [ $? -eq 0 ] && [ $exp_timestamp -le $today_timestamp ]; then
            echo "Deleting expired user: $username (expired: $exp_date)"
            rm -f /etc/zivpn/${username}IP
            rm -f /home/vps/public_html/zivpn-${username}.txt
            rm -f /etc/zivpn/akun/log-create-${username}.log
            rm -f /etc/cron.d/trialzivpn${username}
            deleted=1
        else
            echo "$line" >> "$temp_file"
        fi
    else
        echo "$line" >> "$temp_file"
    fi
done < "$ZIVPN_USERS"

mv "$temp_file" "$ZIVPN_USERS"

if [ $deleted -eq 1 ]; then
    echo "Updating ZIVPN configuration..."
    update_zivpn_config
    echo "Expired users cleanup completed at $(date)"
else
    echo "No expired users found at $(date)"
fi

exit 0
EOFSCRIPT

chmod +x /usr/bin/hapus-expired-zivpn

# Create crontab for auto-delete
cat > /etc/cron.d/hapus-expired-zivpn << 'EOFCRON'
# Auto Delete Expired ZIVPN Accounts
# Run every day at 00:00 (midnight)
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0 0 * * * root /usr/bin/hapus-expired-zivpn >> /var/log/zivpn-cleanup.log 2>&1
EOFCRON

chmod 644 /etc/cron.d/hapus-expired-zivpn

echo -e "✓ Auto-delete expired accounts configured"
echo -e "ZIVPN UDP Installed"
clear

