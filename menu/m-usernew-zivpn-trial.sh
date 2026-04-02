#!/bin/bash
# ZIVPN Trial Account Creator
# Extracted from m-zivpn.sh

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

if [ ! -e /etc/zivpn/akun ]; then
    mkdir -p /etc/zivpn/akun
fi

# Helper function to update config.json (passwords only)
function update_zivpn_config() {
    local passwords_array="["
    local first=true
    
    # Always include default password "zi" first
    passwords_array="$passwords_array\"zi\""
    first=false
    
    # Add user passwords from users.txt
    while IFS= read -r line; do
        if [[ $line =~ ^###\ (.*)\ (.*)\ (.*)$ ]]; then
            pass="${BASH_REMATCH[3]}"
            # Skip if password is "zi" (already added)
            if [ "$pass" != "zi" ]; then
                passwords_array="$passwords_array,\"$pass\""
            fi
        fi
    done < "$ZIVPN_USERS"
    
    passwords_array="$passwords_array]"
    
    # Update config.json
    if command -v jq &> /dev/null; then
        jq ".auth.config = $passwords_array" $ZIVPN_CONFIG > ${ZIVPN_CONFIG}.tmp && mv ${ZIVPN_CONFIG}.tmp $ZIVPN_CONFIG
    else
        echo "Warning: jq not installed, cannot update config.json"
        return 1
    fi
    
    # Restart service
    systemctl restart zivpn >/dev/null 2>&1
    sleep 2
    
    # Verify service started
    if ! systemctl is-active --quiet zivpn; then
        echo "Warning: ZIVPN service failed to restart"
        return 1
    fi
}

clear
IP=$(curl -sS ifconfig.me)
cd
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}           ${WH}• TRIAL ZIVPN Account •          ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e ""
until [[ $timer =~ ^[0-9]+$ ]]; do
read -p "Expired (Minutes): " timer
done
Login=Trial-`</dev/urandom tr -dc X-Z0-9 | head -c4`
hari=0
Pass=$Login
iplim=1
if [ -z ${iplim} ]; then
iplim="0"
fi
echo "$iplim" > /etc/zivpn/${Login}IP
expi=`date -d "$hari days" +"%Y-%m-%d"`
exp="$(date -d "$hari days" +"%Y-%m-%d")"
echo -e "### $Login $expi $Pass" >> $ZIVPN_USERS
update_zivpn_config
cat > /home/vps/public_html/zivpn-$Login.txt <<-END
_______________________________
Format ZIVPN Account
_______________________________
Username         : $Login
Password         : $Pass
Expired          : $timer Minutes
_______________________________
Host             : $domain
ISP              : $ISP
CITY             : $CITY
Login Limit      : ${iplim} IP
Port ZIVPN       : $ZIVPN_PORT
_______________________________
END
TEXT="
◇━━━━━━━━━━━━━━━━━◇
Trial ZIVPN Premium Account
◇━━━━━━━━━━━━━━━━━◇
Username        :  <code>$Login</code>
Password        :  <code>$Pass</code>
Expired On      :  $timer Minutes
◇━━━━━━━━━━━━━━━━━◇
ISP             :  $ISP
CITY            :  $CITY
Host            :  <code>$domain</code>
Login Limit     :  ${iplim} IP
Port ZIVPN      :  $ZIVPN_PORT
◇━━━━━━━━━━━━━━━━━◇
Save Link Account: http://$domain:89/zivpn-$Login.txt
◇━━━━━━━━━━━━━━━━━◇
$author
◇━━━━━━━━━━━━━━━━━◇
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
cat> /etc/cron.d/trialzivpn${Login} << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$timer * * * * root /usr/bin/trial zivpn $Login $Pass $expi
EOF
clear
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC} ${WH}• Trial ZIVPN Premium Account • " | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Username   ${COLOR1}: ${WH}$Login"  | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Password   ${COLOR1}: ${WH}$Pass" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Expired On ${COLOR1}: ${WH}$timer Minutes"  | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}ISP        ${COLOR1}: ${WH}$ISP" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}City       ${COLOR1}: ${WH}$CITY" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Host       ${COLOR1}: ${WH}$domain" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Login Limit${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Port ZIVPN ${COLOR1}: ${WH}$ZIVPN_PORT" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}  ${WH}Save Link Acount    : " | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}  ${WH}http://$domain:89/zivpn-$Login.txt${NC}$COLOR1 $NC" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}    ${WH}• $author •${NC}                 $COLOR1 $NC" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo "" | tee -a /etc/zivpn/akun/log-create-${Login}.log
read -n 1 -s -r -p "Press any key to back on menu"
menu
