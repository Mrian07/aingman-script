#!/bin/bash
# ZIVPN Account Creator
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
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}               ${WH}• ZIVPN PANEL MENU •             ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e " "
until [[ $Login =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
read -p "   Username   : " Login
CLIENT_EXISTS=$(grep -w $Login $ZIVPN_USERS | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e " "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}               ${WH}• ZIVPN PANEL MENU •             ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1│${WH} Nama Duplikat Silahkan Buat Nama Lain.          $COLOR1│"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e " "
fi
done
Pass=$Login
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "   Limit User : " iplim
done
until [[ $masaaktif =~ ^[0-9]+$ ]]; do
read -p "   Masa Aktif : " masaaktif
done
if [ -z ${iplim} ]; then
iplim="0"
fi
echo "${iplim}" >/etc/zivpn/${Login}IP
IP=$(curl -sS ifconfig.me);
sleep 1
clear
expi=`date -d "$masaaktif days" +"%Y-%m-%d"`
exp="$(date -d "$masaaktif days" +"%Y-%m-%d")"
echo -e "### $Login $expi $Pass" >> $ZIVPN_USERS
update_zivpn_config
cat > /home/vps/public_html/zivpn-$Login.txt <<-END
_______________________________
Format ZIVPN Account
_______________________________
Username         : $Login
Password         : $Pass
Masa Aktif       : $masaaktif Days
Expired          : $exp
_______________________________
Host             : $domain
ISP              : $ISP
CITY             : $CITY
Login Limit      : ${iplim} IP
Port ZIVPN       : $ZIVPN_PORT
_______________________________
ZIVPN UDP        : $domain:6000-19999@$Login:$Pass
_______________________________
END
TEXT="
◇━━━━━━━━━━━━━━━━━◇
ZIVPN Premium Account
◇━━━━━━━━━━━━━━━━━◇
Username        :  <code>$Login</code>
Password        :  <code>$Pass</code>
Expired On       :  $exp
◇━━━━━━━━━━━━━━━━━◇
ISP              :  $ISP
CITY             :  $CITY
Host             :  <code>$domain</code>
Login Limit      :  ${iplim} IP
Port ZIVPN       :  $ZIVPN_PORT
◇━━━━━━━━━━━━━━━━━◇
ZIVPN UDP        :  <code>$domain:6000-19999@$Login:$Pass</code>
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
user2=$(echo "$Login" | cut -c 1-3)
TIME2=$(date +'%Y-%m-%d %H:%M:%S')
TEXT2="
<code>◇━━━━━━━━━━━━━━━━━◇</code>
<b>   PEMBELIAN ZIVPN SUCCES </b>
<code>◇━━━━━━━━━━━━━━━━━◇</code>
<b>DOMAIN  :</b> <code>${domain} </code>
<b>CITY    :</b> <code>$CITY </code>
<b>DATE    :</b> <code>${TIME2} WIB </code>
<b>DETAIL  :</b> <code>Trx ZIVPN </code>
<b>USER    :</b> <code>${user2}xxx </code>
<b>IP      :</b> <code>${iplim} IP </code>
<b>DURASI  :</b> <code>$masaaktif Hari </code>
<code>◇━━━━━━━━━━━━━━━━━◇</code>
<i>Notif Pembelian Akun ZIVPN..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e " "
echo -e " "
echo -e "$COLOR1${NC} ${WH}• ZIVPN Premium Account  • " | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━ ACCOUNT ZIVPN ━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Username ${COLOR1}: ${WH}$Login"  | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Password ${COLOR1}: ${WH}$Pass" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}ISP  ${COLOR1}: ${WH}$ISP" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}City ${COLOR1}: ${WH}$CITY" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Host ${COLOR1}: ${WH}$domain" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Limit IP ${COLOR1}: ${WH}${iplim} User" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Port ZIVPN ${COLOR1}: ${WH}$ZIVPN_PORT" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}ZIVPN UDP ${COLOR1}: ${WH}$domain:6000-19999@$Login:$Pass" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Masa Aktif ${COLOR1}: ${WH}$masaaktif Days" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Expired On ${COLOR1}: ${WH}$exp"  | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1${NC}Terimakasih Sudah Order Di " | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━${WH}• $author • $NC"━━━◇ | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo "" | tee -a /etc/zivpn/akun/log-create-${Login}.log
