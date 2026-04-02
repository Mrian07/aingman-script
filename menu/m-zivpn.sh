#!/bin/bash
# ZIVPN Management Menu - Compatible with install-zivpn.sh
# Format: Only passwords in config.json, user tracking in users.txt

biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
colornow=$(cat /etc/rmbl/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
domain=`cat /etc/xray/domain`
CHATID2=$(cat /etc/perlogin/id)
KEY2=$(cat /etc/perlogin/token)
URL2="https://api.telegram.org/bot$KEY2/sendMessage"

# ZIVPN Configuration
ZIVPN_DIR="/etc/zivpn"
ZIVPN_USERS="$ZIVPN_DIR/users.txt"
ZIVPN_CONFIG="$ZIVPN_DIR/config.json"
ZIVPN_PORT=$(jq -r '.listen' $ZIVPN_CONFIG 2>/dev/null | cut -d':' -f2 || echo "5667")

# Create directories if not exist
if [ ! -e $ZIVPN_DIR ]; then
    mkdir -p $ZIVPN_DIR
fi

if [ ! -e $ZIVPN_USERS ]; then
    touch $ZIVPN_USERS
fi

# Helper function to update config.json (passwords only)
function update_zivpn_config() {
    local passwords_array="["
    local first=true
    
    while IFS= read -r line; do
        if [[ $line =~ ^###\ (.*)\ (.*)\ (.*)$ ]]; then
            pass="${BASH_REMATCH[3]}"
            if [ "$first" = true ]; then
                passwords_array="$passwords_array\"$pass\""
                first=false
            else
                passwords_array="$passwords_array,\"$pass\""
            fi
        fi
    done < "$ZIVPN_USERS"
    
    passwords_array="$passwords_array]"
    
    jq ".auth.config = $passwords_array" $ZIVPN_CONFIG > ${ZIVPN_CONFIG}.tmp && mv ${ZIVPN_CONFIG}.tmp $ZIVPN_CONFIG
    systemctl restart zivpn >/dev/null 2>&1
}
