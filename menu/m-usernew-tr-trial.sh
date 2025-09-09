#!/bin/bash
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
function add-tr(){
clear
until [[ $user =~ ^[a-zA-Z0-9_.-]+$ && ${user_EXISTS} == '0' ]]; do
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}${COLBG1}            ${WH}• Trial Trojan Account •             ${NC}$COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e ""
read -rp "User: " -e user
user_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)
if [[ ${user_EXISTS} == '1' ]]; then
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}${COLBG1}            ${WH}• Trial Trojan Account •         ${NC}$COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1│${WH} Nama Duplikat Silahkan Buat Nama Lain.          $COLOR1│"
echo -e "$COLOR1│                                                 │"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
add-tr
fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
until [[ $timer =~ ^[0-9]+$ ]]; do
read -p "Expired (menit): " timer
done
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "Limit User (IP) or 0 Unlimited: " iplim
done
until [[ $Quota =~ ^[0-9]+$ ]]; do
read -p "Limit User (GB) or 0 Unlimited: " Quota
done
if [ ! -e /etc/trojan ]; then
mkdir -p /etc/trojan
fi
if [ ${iplim} = '0' ]; then
iplim="9999"
fi
if [ ${Quota} = '0' ]; then
Quota="9999"
fi
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/trojan/${user}
fi
echo "${iplim}" >/etc/trojan/${user}IP
# Set expired date untuk trial (1 hari karena menggunakan menit untuk auto-delete)
exp=`date -d "1 days" +"%Y-%m-%d"`
sed -i '/#trojanws$/a\#tr '"$user $exp $uuid"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#trojangrpc$/a\#trg '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
trojanlink2="trojan://${uuid}@${domain}:80?security=none&type=ws&path=/trojan-ntls&host=${domain}#${user}"
trojanlink1="trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}"
trojanlink="trojan://${uuid}@${domain}:443?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojan1="trojan://${uuid}@${domain}:443?mode=gun%26security=tls%26type=grpc%26serviceName=trojan-grpc%26sni=${domain}#${user}"
trojan2="trojan://${uuid}@${domain}:443?path=%2Ftrojan-ws%26security=tls%26host=${domain}%26type=ws%26sni=${domain}#${user}"
trojan3="trojan://${uuid}@${domain}:80?security=none%2type=ws%2path=%2Ftrojan-ntls%2host=${domain}#${user}"
# Setup auto delete menggunakan AT Command (seperti SSH trial)
# Install at service jika belum ada
if ! command -v at >/dev/null 2>&1; then
    apt-get update >/dev/null 2>&1
    apt-get install -y at >/dev/null 2>&1
fi
systemctl enable atd >/dev/null 2>&1
systemctl start atd >/dev/null 2>&1

# Buat script auto delete dengan force disconnect
cat > /tmp/delete_trial_trojan_${user}.sh << 'EOFSCRIPT'
#!/bin/bash
# Auto delete script untuk trial trojan user: ${user}
USER="${user}"
UUID="${uuid}"
EXP="${exp}"

echo "Starting auto delete for trojan user: $USER"

# Force kill processes untuk trojan connections
pkill -f "trojan.*$USER" >/dev/null 2>&1
pkill -f "xray.*trojan.*$USER" >/dev/null 2>&1

# Delete user dari config trojan
sed -i "/^#tr $USER $EXP/,/^},{/d" /etc/xray/config.json >/dev/null 2>&1
sed -i "/^#trg $USER $EXP/,/^},{/d" /etc/xray/config.json >/dev/null 2>&1

# Clean files
rm /home/vps/public_html/trojan-$USER.txt >/dev/null 2>&1
rm /etc/trojan/${USER} >/dev/null 2>&1
rm /etc/trojan/${USER}IP >/dev/null 2>&1
rm /etc/trojan/akun/log-create-${USER}.log >/dev/null 2>&1

# Add to delete log
if [ ! -e /etc/trojan/akundelete ]; then
    echo "" > /etc/trojan/akundelete
fi
echo "### $USER $EXP $UUID" >> /etc/trojan/akundelete

# Restart xray service
systemctl restart xray >/dev/null 2>&1

# Cleanup script
rm /tmp/delete_trial_trojan_${USER}.sh >/dev/null 2>&1

echo "Auto delete completed for trojan user: $USER"
EOFSCRIPT

# Replace variables in script
sed -i "s/\${user}/$user/g" /tmp/delete_trial_trojan_${user}.sh
sed -i "s/\${uuid}/$uuid/g" /tmp/delete_trial_trojan_${user}.sh
sed -i "s/\${exp}/$exp/g" /tmp/delete_trial_trojan_${user}.sh
chmod +x /tmp/delete_trial_trojan_${user}.sh
echo "/tmp/delete_trial_trojan_${user}.sh" | at now + ${timer} minutes >/dev/null 2>&1
cat > /home/vps/public_html/trojan-$user.txt <<-END
_______________________________
Format Trojan WS (CDN) - TRIAL
_______________________________
- name: Trojan-$user-WS (CDN)
server: ${domain}
port: 443
type: trojan
password: ${uuid}
network: ws
sni: ${domain}
skip-cert-verify: true
udp: true
ws-opts:
path: /trojan-ws
headers:
Host: ${domain}
_______________________________
Format Trojan gRPC - TRIAL
_______________________________
- name: Trojan-$user-gRPC (SNI)
type: trojan
server: ${domain}
port: 443
password: ${uuid}
udp: true
sni: ${domain}
skip-cert-verify: true
network: grpc
grpc-opts:
grpc-service-name: trojan-grpc
_______________________________
Link Trojan Account - TRIAL
_______________________________
Link WS : trojan://${uuid}@${domain}:443?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}
_______________________________
Link GRPC : trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}
_______________________________
END
if [ ${Quota} = '9999' ]; then
TEXT="
◇━━━━━━━━━━━━━━━━━◇
Trial Trojan Account
◇━━━━━━━━━━━━━━━━━◇
User         : ${user}
Domain       : <code>${domain}</code>
Login Limit   : ${iplim} IP
ISP          : ${ISP}
CITY         : ${CITY}
Port NTLS    : 80
Port TLS     : 443
Port gRPC    : 443
UUID         : <code>${uuid}</code>
AlterId      : 0
Security     : auto
Network      : NTLS, WS or gRPC
Path TLS     : <code>/trojan-ws</code>
Path gRPC    : <code>/trojan-grpc</code>
◇━━━━━━━━━━━━━━━━━◇
Link NTLS    :
<code>${trojan3}</code>
◇━━━━━━━━━━━━━━━━━◇
Link TLS    :
<code>${trojan2}</code>
◇━━━━━━━━━━━━━━━━━◇
Link GRPC    :
<code>${trojan1}</code>
◇━━━━━━━━━━━━━━━━━◇
Format OpenClash :
http://$domain:89/trojan-$user.txt
◇━━━━━━━━━━━━━━━━━◇
Expired Until    :  $timer Minutes
◇━━━━━━━━━━━━━━━━━◇
$author
◇━━━━━━━━━━━━━━━━━◇
"
else
TEXT="
◇━━━━━━━━━━━━━━━━━◇
Trial Trojan Account
◇━━━━━━━━━━━━━━━━━◇
User         : ${user}
Domain       : <code>${domain}</code>
Login Limit   : ${iplim} IP
Quota Limit  : ${Quota} GB
ISP          : ${ISP}
CITY         : ${CITY}
Port NTLS    : 80
Port TLS     : 443
Port gRPC    : 443
UUID         : <code>${uuid}</code>
AlterId      : 0
Security     : auto
Network      : NTLS, WS or gRPC
Path TLS     : <code>/trojan-ws</code>
Path gRPC    : <code>/trojan-grpc</code>
◇━━━━━━━━━━━━━━━━━◇
Link NTLS    :
<code>${trojan3}</code>
◇━━━━━━━━━━━━━━━━━◇
Link TLS    :
<code>${trojan2}</code>
◇━━━━━━━━━━━━━━━━━◇
Link GRPC    :
<code>${trojan1}</code>
◇━━━━━━━━━━━━━━━━━◇
Format OpenClash :
http://$domain:89/trojan-$user.txt
◇━━━━━━━━━━━━━━━━━◇
Expired Until    :  $timer Minutes
◇━━━━━━━━━━━━━━━━━◇
$author
◇━━━━━━━━━━━━━━━━━◇
"
fi
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
user2=$(echo "$user" | cut -c 1-3)
TIME2=$(date +'%Y-%m-%d %H:%M:%S')
TEXT2="
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<b>   PEMBELIAN TROJAN TRIAL SUCCES </b>
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<b>DOMAIN  :</b> <code>${domain} </code>
<b>CITY    :</b> <code>$CITY </code>
<b>DATE    :</b> <code>${TIME2} WIB </code>
<b>DETAIL  :</b> <code>Trx TROJAN TRIAL </code>
<b>USER    :</b> <code>${user2}xxx </code>
<b>IP      :</b> <code>${iplim} IP </code>
<b>DURASI  :</b> <code>$timer Menit </code>
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<i>Notif Pembelian Akun Trojan Trial..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}• Trial Trojan Account •  ${NC} $COLOR1 $NC" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}User         ${COLOR1}: ${WH}${user}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}ISP          ${COLOR1}: ${WH}$$ISP" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}City         ${COLOR1}: ${WH}$$CITY" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Host         ${COLOR1}: ${WH}${domain}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Login Limit  ${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/trojan/akun/log-create-${user}.log
if [ ${Quota} = '9999' ]; then
echo -ne
else
echo -e "$COLOR1 ${NC} ${WH}Quota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/trojan/akun/log-create-${user}.log
fi
echo -e "$COLOR1 ${NC} ${WH}Port NTLS    ${COLOR1}: ${WH}80" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Key          ${COLOR1}: ${WH}${uuid}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Path NTLS    ${COLOR1}: ${WH}/trojan-ntls" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Path WS      ${COLOR1}: ${WH}/trojan-ws" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Path gRPC    ${COLOR1}: ${WH}/trojan-grpc" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Link NTLS    ${COLOR1}: " | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}${trojanlink2}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Link TLS     ${COLOR1}: " | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}${trojanlink}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Link gRPC    ${COLOR1}: " | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}${trojanlink1}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Format Openclash ${COLOR1}: " | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}http://$domain:89/trojan-$user.txt${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}Expired Until   ${COLOR1}: ${WH}$timer Minutes" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ${NC} ${WH}    $author     " | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo "" | tee -a /etc/trojan/akun/log-create-${user}.log
systemctl restart xray > /dev/null 2>&1
}
add-tr
