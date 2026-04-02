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

function usernew(){
clear
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
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
read -n 1 -s -r -p "Press any key to back"
usernew
fi
read -p "   Password   : " Pass
done
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
echo -e "$COLOR1$NC${WH}Masa Aktif ${COLOR1}: ${WH}$masaaktif" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Expired On ${COLOR1}: ${WH}$exp"  | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1${NC}Terimakasih Sudah Order Di " | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━${WH}• $author • $NC"━━━◇ | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo "" | tee -a /etc/zivpn/akun/log-create-${Login}.log
read -n 1 -s -r -p "Press any key to back on menu"
m-zivpn
}

function trial(){
clear
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
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
Pass=1
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
m-zivpn
}

function renew(){
clear
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
domain=$(cat /etc/xray/domain)
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$ZIVPN_USERS")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• RENEW USERS •                    │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1│${WH} User Tidak Ada!                              $COLOR1   │"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-zivpn
fi
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• RENEW USERS •                    │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│ ${WH}Silahkan Pilih User Yang Mau di Renew$COLOR1           │"
echo -e "$COLOR1│ ${WH}ketik [0] kembali kemenu$COLOR1                        │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Select one client [1]: " CLIENT_NUMBER
else
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-zivpn
fi
fi
done
User=$(grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
Pass=$(grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
read -p "Day Extend : " Days
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $Days))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/### $User $exp/### $User $exp4/g" $ZIVPN_USERS >/dev/null
update_zivpn_config
clear
TEXT="
<code>◇━━━━━━━━━━━━━━◇</code>
<b>  ZIVPN RENEW</b>
<code>◇━━━━━━━━━━━━━━◇</code>
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>USERNAME :</b> <code>$User </code>
<b>EXPIRED  :</b> <code>$exp4 </code>
<code>◇━━━━━━━━━━━━━━◇</code>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
user2=$(echo "$User" | cut -c 1-3)
TIME2=$(date +'%Y-%m-%d %H:%M:%S')
TEXT2="
<code>◇━━━━━━━━━━━━━━◇</code>
<b>   TRANSAKSI SUCCES </b>
<code>◇━━━━━━━━━━━━━━◇</code>
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$CITY </code>
<b>DATE   :</b> <code>${TIME2} WIB</code>
<b>DETAIL   :</b> <code>Trx ZIVPN </code>
<b>USER :</b> <code>${user2}xxx </code>
<b>DURASI  :</b> <code>$Days Hari </code>
<code>◇━━━━━━━━━━━━━━◇</code>
<i>Renew Account From Server..</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}              ${WH}• RENEW USERS •                    │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│"
echo -e "$COLOR1│ ${WH}Username   : $User"
echo -e "$COLOR1│ ${WH}Days Added : $Days Days"
echo -e "$COLOR1│ ${WH}Expired on : $exp4"
echo -e "$COLOR1│"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
m-zivpn
}

function hapus(){
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$ZIVPN_USERS")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}              ${WH}• DELETE USERS •                   │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1│${WH} User Tidak Ada!                              $COLOR1   │"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-zivpn
fi
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}              ${WH}• DELETE USERS •                   │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│ ${WH}Pilih mode delete:                           $COLOR1    │"
echo -e "$COLOR1│ ${WH}[1] Single User Delete                       $COLOR1    │"
echo -e "$COLOR1│ ${WH}[2] Multiple Users Delete                    $COLOR1    │"
echo -e "$COLOR1│ ${WH}[3] Delete All Trial Users                   $COLOR1    │"
echo -e "$COLOR1│ ${WH}[0] Kembali ke menu                          $COLOR1    │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
read -rp "Pilih mode [1-3]: " delete_mode

if [[ $delete_mode == "0" ]]; then
    m-zivpn
elif [[ $delete_mode == "1" ]]; then
    # SINGLE USER DELETE
    clear
    echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1│${NC}              ${WH}• DELETE SINGLE USER •             │${NC}$COLOR1$NC"
    echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
    echo -e " "
    echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1│ ${WH}Silahkan Pilih User Yang Mau Didelete       $COLOR1    │"
    echo -e "$COLOR1│ ${WH}ketik [0] kembali kemenu                     $COLOR1   │"
    echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
    grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 2-3 | nl -s ') '
    until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    if [[ ${CLIENT_NUMBER} == '1' ]]; then
    read -rp "Select one client [1]: " CLIENT_NUMBER
    else
    read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
    if [[ ${CLIENT_NUMBER} == '0' ]]; then
    m-zivpn
    fi
    fi
    done
    Pengguna=$(grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
    Days=$(grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
    Pass=$(grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
    echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1│ ${WH}Konfirmasi Delete User: ${WH}$Pengguna             $COLOR1│"
    echo -e "$COLOR1│ ${WH}Expired: $Days                               $COLOR1│"
    echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
    read -rp "Yakin ingin delete user ini? [y/n]: " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        sed -i "/^### $Pengguna $Days $Pass/d" $ZIVPN_USERS
        rm /home/vps/public_html/zivpn-$Pengguna.txt >/dev/null 2>&1
        rm /etc/zivpn/${Pengguna}IP >/dev/null 2>&1
        update_zivpn_config
        echo -e "User $Pengguna was removed."
        TEXT="
<code>◇━━━━━━━━━━━━━━◇</code>
<b>  DELETE ZIVPN</b>
<code>◇━━━━━━━━━━━━━━◇</code>
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>USERNAME :</b> <code>$Pengguna </code>
<b>EXPIRED  :</b> <code>$Days </code>
<code>◇━━━━━━━━━━━━━━◇</code>
<i>Succes Delete This User...</i>
"
        curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
        cd
        if [ ! -e /etc/tele ]; then
        echo -ne
        else
        echo "$TEXT" > /etc/notiftele
        bash /etc/tele
        fi
    else
        echo "Delete dibatalkan."
    fi

elif [[ $delete_mode == "2" ]]; then
    # MULTIPLE USERS DELETE
    clear
    echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1│${NC}              ${WH}• DELETE MULTIPLE USERS •          │${NC}$COLOR1$NC"
    echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
    echo -e " "
    echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1│ ${WH}Masukkan nomor user (contoh: 1,3,5 atau 1-5) $COLOR1    │"
    echo -e "$COLOR1│ ${WH}ketik 'all' untuk delete semua user          $COLOR1    │"
    echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
    grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 2-3 | nl -s ') '
    read -rp "Masukkan pilihan: " selection
    if [[ $selection == "all" ]]; then
        read -rp "Yakin delete SEMUA? ketik 'DELETE ALL': " confirm_all
        if [[ $confirm_all == "DELETE ALL" ]]; then
            > $ZIVPN_USERS
            update_zivpn_config
            echo "Semua user berhasil dihapus."
        fi
    fi

elif [[ $delete_mode == "3" ]]; then
    # DELETE ALL TRIAL USERS
    trial_count=$(grep -E "^### trial-" "$ZIVPN_USERS" | wc -l)
    if [[ $trial_count -eq 0 ]]; then
        echo "Tidak ada user trial."
    else
        read -rp "Delete $trial_count trial users? ketik 'DELETE TRIAL': " confirm_trial
        if [[ $confirm_trial == "DELETE TRIAL" ]]; then
            sed -i "/^### trial-/d" $ZIVPN_USERS
            update_zivpn_config
            echo "Semua trial user berhasil dihapus."
        fi
    fi
fi
read -n 1 -s -r -p "Press any key to back on menu"
m-zivpn
}

function cekconfig(){
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
domain=$(cat /etc/xray/domain)
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$ZIVPN_USERS")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}              ${WH}• USER CONFIG •                    │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1│${WH} User Tidak Ada!                              $COLOR1   │"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-zivpn
fi
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}              ${WH}• USER CONFIG •                    │${NC}$COLOR1$NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│ ${WH}Silahkan Pilih User Yang Mau Dicek     $COLOR1         │"
echo -e "$COLOR1│ ${WH}ketik [0] kembali kemenu                     $COLOR1   │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Select one client [1]: " CLIENT_NUMBER
else
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-zivpn
fi
fi
done
Login=$(grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
cat /etc/zivpn/akun/log-create-${Login}.log
cat /etc/zivpn/akun/log-create-${Login}.log > /etc/notifakun
sed -i 's/\x1B\[1;37m//g' /etc/notifakun
sed -i 's/\x1B\[0;96m//g' /etc/notifakun
sed -i 's/\x1B\[0m//g' /etc/notifakun
TEXT=$(cat /etc/notifakun)
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
read -n 1 -s -r -p "   Press any key to back on menu"
m-zivpn
}

function limitssh(){
cd
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$ZIVPN_USERS")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "$COLOR1 ${NC}${COLBG1}    ${WH}⇱ Limit ZIVPN Account ⇲        ${NC} $COLOR1 $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "You have no existing clients!"
echo ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-zivpn
fi
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "$COLOR1 ${NC}${COLBG1}    ${WH}⇱ Limit ZIVPN Account ⇲        ${NC} $COLOR1 $NC"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Select the existing client you want to change ip"
echo " ketik [0] kembali kemenu"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Select one client [1]: " CLIENT_NUMBER
else
read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-zivpn
fi
fi
done
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "Limit User (IP) New: " iplim
done
if [ -z ${iplim} ]; then
iplim="0"
fi
user=$(grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "$ZIVPN_USERS" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
echo "${iplim}" >/etc/zivpn/${user}IP
TEXT="
<code>◇━━━━━━━━━━━━━━◇</code>
<b>  ZIVPN IP LIMIT</b>
<code>◇━━━━━━━━━━━━━━◇</code>
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>USERNAME :</b> <code>$user </code>
<b>EXPIRED  :</b> <code>$exp </code>
<b>IP LIMIT NEW :</b> <code>$iplim IP </code>
<code>◇━━━━━━━━━━━━━━◇</code>
<i>Succes Change IP LIMIT...</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
clear
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " ZIVPN Account Was Successfully Change Limit IP"
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Client Name : $user"
echo " Limit IP    : $iplim IP"
echo ""
echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-zivpn
}

function cek(){
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
domain=$(cat /etc/xray/domain)
author=$(cat /etc/profil)
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC} ${COLBG1}             ${WH}• ZIVPN ACTIVE USERS •            ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo ""
echo "Checking ZIVPN active connections..."
systemctl status zivpn --no-pager | grep -i "active"
echo ""
echo "Total registered users:"
grep -c -E "^### " "$ZIVPN_USERS"
echo ""
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
m-zivpn
}

clear
author=$(cat /etc/profil)
echo -e " $COLOR1╭════════════════════════════════════════════════════╮${NC}"
echo -e " $COLOR1│${NC}                ${WH}• ZIVPN PANEL MENU •              ${NC} $COLOR1│ $NC"
echo -e " $COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e " $COLOR1╭══════════════════════════════════════════════════════╮${NC}"
echo -e " $COLOR1│ $NC  ${COLOR1}[${WH}01${COLOR1}]${NC} ${COLOR1}• ${WH}CREATE ACCOUNT${NC}   ${COLOR1}[${WH}05${COLOR1}]${NC} ${COLOR1}• ${WH}CEK USER ONLINE${NC}    $COLOR1│ $NC"
echo -e " $COLOR1│ $NC  ${COLOR1}[${WH}02${COLOR1}]${NC} ${COLOR1}• ${WH}TRIAL ACCOUNT${NC}    ${COLOR1}[${WH}06${COLOR1}]${NC} ${COLOR1}• ${WH}CEK ACCOUNT CONFIG${NC} $COLOR1│ $NC"
echo -e " $COLOR1│ $NC  ${COLOR1}[${WH}03${COLOR1}]${NC} ${COLOR1}• ${WH}RENEW ACCOUNT${NC}    ${COLOR1}[${WH}07${COLOR1}]${NC} ${COLOR1}• ${WH}CHANGE IP LIMIT${NC}    $COLOR1│ $NC"
echo -e " $COLOR1│ $NC  ${COLOR1}[${WH}04${COLOR1}]${NC} ${COLOR1}• ${WH}DELETE ACCOUNT${NC}   ${COLOR1}[${WH}00${COLOR1}]${NC} ${COLOR1}• ${WH}GO BACK${NC}           $COLOR1 │$NC"
echo -e " $COLOR1╰══════════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e " $COLOR1╭═════════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮ ${NC}"
echo -e "  $COLOR1${NC}              ${WH}   • $author •                 $COLOR1 $NC"
echo -e " $COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo -e ""
echo -ne " ${WH} Select menu ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; usernew ; exit ;;
02 | 2) clear ; trial ; exit ;;
03 | 3) clear ; renew ; exit ;;
04 | 4) clear ; hapus ; exit ;;
05 | 5) clear ; cek ; exit ;;
06 | 6) clear ; cekconfig ; exit ;;
07 | 7) clear ; limitssh; exit ;;
00 | 0) clear ; menu ; exit ;;
X  | 0) clear ; m-zivpn ;;
x) exit ;;
*) echo "Anda salah tekan " ; sleep 1 ; m-zivpn ;;
esac
