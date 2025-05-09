#!/bin/bash
function usernew(){
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
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}               ${WH}• SSH PANEL MENU •               ${NC} $COLOR1│ $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e " "
until [[ $Login =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
read -p "   Username   : " Login
CLIENT_EXISTS=$(grep -w $Login /etc/xray/ssh | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e " "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│${NC}               ${WH}• SSH PANEL MENU •               ${NC} $COLOR1│ $NC"
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
if [ ! -e /etc/xray/sshx ]; then
mkdir -p /etc/xray/sshx
fi
if [ -z ${iplim} ]; then
iplim="0"
fi
echo "${iplim}" >/etc/xray/sshx/${Login}IP
IP=$(curl -sS ifconfig.me);
if [[ -e /etc/cloudfront ]]; then
cloudfront=$(cat /etc/cloudfront)
else
cloudfront="-"
fi
sleep 1
clear
expi=`date -d "$masaaktif days" +"%Y-%m-%d"`
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e "### $Login $expi $Pass" >> /etc/xray/ssh
cat > /home/vps/public_html/ssh-$Login.txt <<-END
_______________________________
Format SSH OVPN Account
_______________________________
Username         : $Login
Password         : $Pass
Masa Aktif       : $masaaktif Days
Expired          : $exp
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
SSH Premium Account
◇━━━━━━━━━━━━━━━━━◇
Username        :  <code>$Login</code>
Password        :  <code>$Pass</code>
Expired On       :  $exp
◇━━━━━━━━━━━━━━━━━◇
ISP              :  $ISP
CITY             :  $CITY
Host             :  <code>$domen</code>
Login Limit      :  ${iplim} IP
Port OpenSSH    :  22
Port Dropbear    :  109, 143
Port SSH WS     :  80, 7788, 8181, 8282
Port SSH SSL WS :  443
Port SSL/TLS     :  8443,8880
Port OVPN WS SSL :  2086
Port OVPN SSL    :  990
Port OVPN TCP    :  1194
Port OVPN UDP    :  2200
Proxy Squid        :  3128
BadVPN UDP       :  7100, 7300, 7300
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
SSH Premium Account
◇━━━━━━━━━━━━━━━━━◇
Username        :  <code>$Login</code>
Password        :  <code>$Pass</code>
Masa Aktif      :  $masaaktif
Expired On      :  $exp
◇━━━━━━━━━━━━━━━━━◇
ISP              :  $ISP
CITY             :  $CITY
Host             :  <code>$domen</code>
Login Limit      :  ${iplim} IP
Port OpenSSH     :  22
Port Dropbear    :  109, 143
Port SSH WS      :  80, 7788, 8181, 8282
Port SSH SSL WS  :  443
Port SSL/TLS     :  8443,8880
Port OVPN WS SSL :  2086
Port OVPN SSL    :  990
Port OVPN TCP    :  1194
Port OVPN UDP    :  2200
Proxy Squid      :  3128
BadVPN UDP       :  7100, 7300, 7300
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
user2=$(echo "$Login" | cut -c 1-3)
TIME2=$(date +'%Y-%m-%d %H:%M:%S')
TEXT2="
<code>◇━━━━━━━━━━━━━━━━━◇</code>
<b>   PEMBELIAN SSH SUCCES </b>
<code>◇━━━━━━━━━━━━━━━━━◇</code>
<b>DOMAIN  :</b> <code>${domain} </code>
<b>CITY    :</b> <code>$CITY </code>
<b>DATE    :</b> <code>${TIME2} WIB </code>
<b>DETAIL  :</b> <code>Trx SSH </code>
<b>USER    :</b> <code>${user2}xxx </code>
<b>IP      :</b> <code>${iplim} IP </code>
<b>DURASI  :</b> <code>$masaaktif Hari </code>
<code>◇━━━━━━━━━━━━━━━━━◇</code>
<i>Notif Pembelian Akun Ssh..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e " "
echo -e " "
echo -e "$COLOR1${NC} ${WH}• SSH Premium Account  • " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━ ACCOUNT SSH ━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Username ${COLOR1}: ${WH}$Login"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Password ${COLOR1}: ${WH}$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}ISP  ${COLOR1}: ${WH}$ISP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}City ${COLOR1}: ${WH}$CITY" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Host ${COLOR1}: ${WH}$domen" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Limit IP ${COLOR1}: ${WH}${iplim} User" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}SSH : ${WH}$domen:80@$Login:$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Masa Aktif ${COLOR1}: ${WH}$masaaktif" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Expired On ${COLOR1}: ${WH}$exp"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━ PORT ━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}OpenSSH  ${COLOR1}: ${WH}22" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Dropbear ${COLOR1}: ${WH}109, 143" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}SSH WS   ${COLOR1}: ${WH}80, 2086, 7000 s/d 9000, etc" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}SSH SSL  ${COLOR1}: ${WH}443, 990" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}SSL/TLS  ${COLOR1}: ${WH}443,8880" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}Ovpn Ws  ${COLOR1}: ${WH}2086" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}TCP ${COLOR1}: ${WH}1194" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}UDP ${COLOR1}: ${WH}2200,1-65535" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}UDPGW ${COLOR1}: ${WH}7100-7300" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}SLOWDNS${COLOR1}: ${WH}80,443,53" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}NAMESERVER ${COLOR1}: ${WH}$sldomain" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}PUB KEY    ${COLOR1}: ${WH}$slkey" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━ SSH ━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}WS : ${WH}$domen:80@$Login:$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}SSL: ${WH}$domen:443@$Login:$Pass"| tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1$NC${WH}UDP: ${WH}$domen:1-65535@$Login:$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━ PAYLOAD ━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1${NC}${WH}GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1${NC}Terimakasih Sudah Order Di " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "$COLOR1 ◇━━━${WH}• $author • $NC"━━━◇ | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo "" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
}
usernew