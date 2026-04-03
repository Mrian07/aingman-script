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
# Set expired date untuk trial (hari ini karena menggunakan menit)
expi=`date +"%Y-%m-%d"`
exp="$(date +"%Y-%m-%d")"
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

# Setup auto delete menggunakan AT Command
# Install at service jika belum ada
if ! command -v at >/dev/null 2>&1; then
    apt-get update >/dev/null 2>&1
    apt-get install -y at >/dev/null 2>&1
fi
systemctl enable atd >/dev/null 2>&1
systemctl start atd >/dev/null 2>&1

# Buat script auto delete
cat > /tmp/delete_trial_zivpn_${Login}.sh << 'EOFSCRIPT'
#!/bin/bash
# Auto delete script untuk trial ZIVPN user: ${Login}
LOGIN="${Login}"
PASS="${Pass}"
EXPI="${expi}"

echo "Starting auto delete for ZIVPN user: $LOGIN"

# Delete dari users.txt
sed -i "/^### $LOGIN $EXPI $PASS/d" /etc/zivpn/users.txt >/dev/null 2>&1

# Remove IP limit file
rm -f /etc/zivpn/${LOGIN}IP >/dev/null 2>&1

# Remove public HTML file
rm -f /home/vps/public_html/zivpn-${LOGIN}.txt >/dev/null 2>&1

# Remove log file
rm -f /etc/zivpn/akun/log-create-${LOGIN}.log >/dev/null 2>&1

# Update config.json (remove password)
if command -v jq &> /dev/null; then
    ZIVPN_CONFIG="/etc/zivpn/config.json"
    ZIVPN_USERS="/etc/zivpn/users.txt"
    
    passwords_array="["
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
    jq ".auth.config = $passwords_array" $ZIVPN_CONFIG > ${ZIVPN_CONFIG}.tmp && mv ${ZIVPN_CONFIG}.tmp $ZIVPN_CONFIG
    
    # Restart service
    systemctl restart zivpn >/dev/null 2>&1
fi

# Cleanup script
rm /tmp/delete_trial_zivpn_${LOGIN}.sh >/dev/null 2>&1

echo "Auto delete completed for ZIVPN user: $LOGIN"
EOFSCRIPT

# Replace variables in script
sed -i "s/\${Login}/$Login/g" /tmp/delete_trial_zivpn_${Login}.sh
sed -i "s/\${Pass}/$Pass/g" /tmp/delete_trial_zivpn_${Login}.sh
sed -i "s/\${expi}/$expi/g" /tmp/delete_trial_zivpn_${Login}.sh
chmod +x /tmp/delete_trial_zivpn_${Login}.sh
echo "/tmp/delete_trial_zivpn_${Login}.sh" | at now + ${timer} minutes >/dev/null 2>&1
delete_info="AT Command (${timer} menit dari sekarang)"

clear
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC} ${WH}• Trial ZIVPN Premium Account • " | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Username   ${COLOR1}: ${WH}$Login"  | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Password   ${COLOR1}: ${WH}$Pass" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Masa Aktif ${COLOR1}: ${WH}$timer Minutes"  | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Expired On ${COLOR1}: ${WH}$exp"  | tee -a /etc/zivpn/akun/log-create-${Login}.log
auto_delete_time=$(date -d "+${timer} minutes" "+%Y-%m-%d %H:%M:%S")
echo -e "$COLOR1 $NC  ${WH}Auto Delete${COLOR1}: ${WH}$auto_delete_time WIB" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}ISP        ${COLOR1}: ${WH}$ISP" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}City       ${COLOR1}: ${WH}$CITY" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Host       ${COLOR1}: ${WH}$domain" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Login Limit${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Port ZIVPN ${COLOR1}: ${WH}$ZIVPN_PORT" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}  ${WH}ZIVPN UDP: ${WH}$domain:6000-19999@$Login:$Pass" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}  ${WH}Save Link Account: " | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}  ${WH}http://$domain:89/zivpn-$Login.txt${NC}$COLOR1 $NC" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}Terimakasih Sudah Order Di " | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}    ${WH}• $author •${NC}                 $COLOR1 $NC" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/zivpn/akun/log-create-${Login}.log
echo "" | tee -a /etc/zivpn/akun/log-create-${Login}.log
