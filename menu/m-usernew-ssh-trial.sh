function trial(){
clear
domen=`cat /etc/xray/domain`
sldomain=`cat /etc/xray/dns`
slkey=`cat /etc/slowdns/server.pub`
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
echo -e "$COLOR1│${NC} ${COLBG1}           ${WH}• TRIAL SSH Account •               ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e ""
until [[ $timer =~ ^[0-9]+$ ]]; do
read -p "Expired (Minutes): " timer
done
Login=Trial-`</dev/urandom tr -dc X-Z0-9 | head -c4`
hari=0
Pass=1
iplim=1
if [ ! -e /etc/xray/sshx ]; then
mkdir -p /etc/xray/sshx
fi
if [ -z ${iplim} ]; then
iplim="0"
fi
if [[ -e /etc/cloudfront ]]; then
cloudfront=$(cat /etc/cloudfront)
else
cloudfront="Kosong"
fi
echo "$iplim" > /etc/xray/sshx/${Login}IP
expi=`date -d "$hari days" +"%Y-%m-%d"`
useradd -e `date -d "$hari days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e "### $Login $expi $Pass" >> /etc/xray/ssh
tmux new-session -d -s $Login "trial ssh $Login $expi $Pass ${timer}"
cat > /home/vps/public_html/ssh-$Login.txt <<-END
_______________________________
Format SSH OVPN Account
_______________________________
Username         : $Login
Password         : $Pass
Expired          : $timer Minutes
_______________________________
Host             : $domen
ISP              : $ISP
CITY             : $CITY
Login Limit      : ${iplim} IP
Port OpenSSH     : 22
Port Dropbear    : 143, 109
Port SSH WS      : 80, 7788, 8181, 8282
Port SSH SSL WS  : 443
Port SSL/TLS     : 8443, 8880
Port OVPN WS SSL : 2086
Port OVPN SSL    : 990
Port OVPN TCP    : 1194
Port OVPN UDP    : 2200,
BadVPN UDP       : 7100, 7300, 7300
_______________________________
Host Slowdns    : $sldomain
Port Slowdns     : 80, 443, 53
Pub Key          : $slkey
_______________________________
SSH UDP VIRAL : $domen:1-65535@$Login:$Pass
_______________________________
HTTP COSTUM : $domen:80@$Login:$Pass
_______________________________
Payload WS/WSS   :
GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]
_______________________________
OpenVPN SSL      : http://$domen:89/ssl.ovpn
OpenVPN TCP      : http://$domen:89/tcp.ovpn
OpenVPN UDP      : http://$domen:89/udp.ovpn
_______________________________
END
if [[ -e /etc/cloudfront ]]; then
TEXT="
◇━━━━━━━━━━━━━━━━━◇
Trial SSH Premium Account
◇━━━━━━━━━━━━━━━━━◇
Username        :  <code>$Login</code>
Password        :  <code>$Pass</code>
Expired On      :  $timer Minutes
◇━━━━━━━━━━━━━━━━━◇
ISP             :  $ISP
CITY            :  $CITY
Host            :  <code>$domen</code>
Login Limit     :  ${iplim} IP
Port OpenSSH    :  22
Port Dropbear   :  109, 143
Port SSH WS :  80, 7788, 8181, 8282
Port SSH SSL WS :  443
Port SSL/TLS    :  8443,8880
Port OVPN WS SSL:  2086
Port OVPN SSL   :  990
Port OVPN TCP   :  1194
Port OVPN UDP   :  2200
Proxy Squid     :  3128
BadVPN UDP :  7100, 7300, 7300
◇━━━━━━━━━━━━━━━━━◇
SSH UDP VIRAL : <code>$domen:1-65535@$Login:$Pass</code>
◇━━━━━━━━━━━━━━━━━◇
HTTP COSTUM WS : <code>$domen:80@$Login:$Pass</code>
◇━━━━━━━━━━━━━━━━━◇
Host Slowdns    :  <code>$sldomain</code>
Port Slowdns     :  80, 443, 53
Pub Key          :  <code> $slkey</code>
◇━━━━━━━━━━━━━━━━━◇
Payload WS/WSS   :
<code>GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]</code>
◇━━━━━━━━━━━━━━━━━◇
OpenVPN SSL      :  http://$domen:89/ssl.ovpn
OpenVPN TCP      :  http://$domen:89/tcp.ovpn
OpenVPN UDP      :  http://$domen:89/udp.ovpn
◇━━━━━━━━━━━━━━━━━◇
Save Link Account: http://$domen:89/ssh-$Login.txt
◇━━━━━━━━━━━━━━━━━◇
$author
◇━━━━━━━━━━━━━━━━━◇
"
else
TEXT="
◇━━━━━━━━━━━━━━━━━◇
Trial SSH Premium Account
◇━━━━━━━━━━━━━━━━━◇
Username        :  <code>$Login</code>
Password        :  <code>$Pass</code>
Expired On      :  $timer Minutes
◇━━━━━━━━━━━━━━━━━◇
ISP             :  $ISP
CITY            :  $CITY
Host            :  <code>$domen</code>
Login Limit     :  ${iplim} IP
Port OpenSSH    :  22
Port Dropbear   :  109, 143
Port SSH WS :  80, 7788, 8181, 8282
Port SSH SSL WS :  443
Port SSL/TLS    :  8443,8880
Port OVPN WS SSL:  2086
Port OVPN SSL   :  990
Port OVPN TCP   :  1194
Port OVPN UDP   :  2200
Proxy Squid     :  3128
BadVPN UDP :  7100, 7300, 7300
◇━━━━━━━━━━━━━━━━━◇
SSH UDP VIRAL : <code>$domen:1-65535@$Login:$Pass</code>
◇━━━━━━━━━━━━━━━━━◇
HTTP COSTUM WS : <code>$domen:80@$Login:$Pass</code>
◇━━━━━━━━━━━━━━━━━◇
Host Slowdns    :  <code>$sldomain</code>
Port Slowdns     :  80, 443, 53
Pub Key          :  <code> $slkey</code>
◇━━━━━━━━━━━━━━━━━◇
Payload WS/WSS   :
<code>GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]</code>
◇━━━━━━━━━━━━━━━━━◇
OpenVPN SSL      :  http://$domen:89/ssl.ovpn
OpenVPN TCP      :  http://$domen:89/tcp.ovpn
OpenVPN UDP      :  http://$domen:89/udp.ovpn
◇━━━━━━━━━━━━━━━━━◇
Save Link Account: http://$domen:89/ssh-$Login.txt
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
cat> /etc/cron.d/trialssh${Login} << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$timer * * * * root /usr/bin/trial ssh $Login $Pass $expi
EOF
clear
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC} ${WH}• Trial SSH Premium Account • " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Username   ${COLOR1}: ${WH}$Login"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Password   ${COLOR1}: ${WH}$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Expired On ${COLOR1}: ${WH}$timer Minutes"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}ISP        ${COLOR1}: ${WH}$ISP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}City       ${COLOR1}: ${WH}$CITY" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Host       ${COLOR1}: ${WH}$domen" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Login Limit${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}OpenSSH    ${COLOR1}: ${WH}22" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Dropbear   ${COLOR1}: ${WH}109, 143" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}SSH-WS     ${COLOR1}: ${WH}80, 7788, 8181, 8282" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}SSH-SSL-WS ${COLOR1}: ${WH}443" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}SSL/TLS    ${COLOR1}: ${WH}8443,8880" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Ovpn Ws    ${COLOR1}: ${WH}2086" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Port TCP   ${COLOR1}: ${WH}1194" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Port UDP   ${COLOR1}: ${WH}2200,1-65535" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}Port SSL   ${COLOR1}: ${WH}990" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}OVPN TCP   ${COLOR1}: ${WH}http://$domen:89/tcp.ovpn" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}OVPN UDP   ${COLOR1}: ${WH}http://$domen:89/udp.ovpn" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}OVPN SSL   ${COLOR1}: ${WH}http://$domen:89/ssl.ovpn" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}UDPGW      ${COLOR1}: ${WH}7100-7300" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}PORT SLWDNS${COLOR1}: ${WH}80,443,53" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}NAMESERVER ${COLOR1}: ${WH}$sldomain" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}PUB KEY    ${COLOR1}: ${WH}$slkey" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 $NC  ${WH}SSH ${COLOR1}: ${WH}$domen:80@$Login:$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}  ${WH}Payload WS/WSS${COLOR1}: ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1${NC}${WH}GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}  ${WH}Save Link Acount    : " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}  ${WH}http://$domen:89/ssh-$Login.txt${NC}$COLOR1 $NC" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ${NC}    ${WH}• $author •${NC}                 $COLOR1 $NC" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo "" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
}
trial
