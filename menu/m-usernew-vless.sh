#!/bin/bash
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
URL="https://api.telegram.org/bot$KEY/sendMessage"
domain=$(cat /etc/xray/domain)
CHATID2=$(cat /etc/perlogin/id)
KEY2=$(cat /etc/perlogin/token)
URL2="https://api.telegram.org/bot$KEY2/sendMessage"
cd
if [ ! -e /etc/vless/akun ]; then
    mkdir -p /etc/vless/akun
fi
function add-vless() {
    clear
    until [[ $user =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
        echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
        echo -e "$COLOR1│${NC} ${COLBG1}           ${WH}• Add Vless Account •               ${NC} $COLOR1│ $NC"
        echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
        echo -e ""
        read -rp "User: " -e user
        CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)
        if [[ ${CLIENT_EXISTS} == '1' ]]; then
            clear
            echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
            echo -e "$COLOR1│${NC} ${COLBG1}           ${WH}• Add Vless Account •               ${NC} $COLOR1│ $NC"
            echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
            echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
            echo -e "$COLOR1│                                                 │"
            echo -e "$COLOR1│${WH} Nama Duplikat Silahkan Buat Nama Lain.          $COLOR1│"
            echo -e "$COLOR1│                                                 │"
            echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
            read -n 1 -s -r -p "Press any key to back"
            add-vless
        fi
    done
    uuid=$(cat /proc/sys/kernel/random/uuid)
    until [[ $masaaktif =~ ^[0-9]+$ ]]; do
        read -p "Expired (hari): " masaaktif
    done
    until [[ $iplim =~ ^[0-9]+$ ]]; do
        read -p "Limit User (IP) or 0 Unlimited: " iplim
    done
    until [[ $Quota =~ ^[0-9]+$ ]]; do
        read -p "Limit User (GB) or 0 Unlimited: " Quota
    done
    if [ ! -e /etc/vless ]; then
        mkdir -p /etc/vless
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
        echo "${d}" >/etc/vless/${user}
    fi
    echo "${iplim}" >/etc/vless/${user}IP
    exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
    sed -i '/#vless$/a\#vl '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
    sed -i '/#vlessgrpc$/a\#vlg '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
    vlesslink1="vless://${uuid}@${domain}:443?path=/vless&security=tls&encryption=none&host=${domain}&type=ws&sni=${domain}#${user}"
    vlesslink2="vless://${uuid}@${domain}:80?path=/vless&security=none&encryption=none&host=${domain}&type=ws#${user}"
    vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"
    vless1="vless://${uuid}@${domain}:443?path=/vless%26security=tls%26encryption=none%26host=${domain}%26type=ws%26sni=${domain}#${user}"
    vless2="vless://${uuid}@${domain}:80?path=/vless%26security=none%26encryption=none%26host=${domain}%26type=ws#${user}"
    vless3="vless://${uuid}@${domain}:443?mode=gun%26security=tls%26encryption=none%26type=grpc%26serviceName=vless-grpc%26sni=${domain}#${user}"
    cat >/home/vps/public_html/vless-$user.txt <<-END
_______________________________
Format Vless WS (CDN)
_______________________________
- name: vless-$user-WS (CDN)
server: ${domain}
port: 443
type: vless
uuid: ${uuid}
cipher: auto
tls: true
skip-cert-verify: true
servername: ${domain}
network: ws
udp: true
ws-opts:
path: /vless
headers:
Host: ${domain}
_______________________________
Format Vless WS (CDN) Non TLS
_______________________________
- name: vless-$user-WS (CDN) Non TLS
server: ${domain}
port: 80
type: vless
uuid: ${uuid}
cipher: auto
tls: false
skip-cert-verify: false
servername: ${domain}
network: ws
ws-opts:
udp: true
path: /vless
headers:
Host: ${domain}
_______________________________
Format Vless gRPC (SNI)
_______________________________
- name: vless-$user-gRPC (SNI)
server: ${domain}
port: 443
type: vless
uuid: ${uuid}
cipher: auto
tls: true
skip-cert-verify: true
servername: ${domain}
network: grpc
grpc-opts:
grpc-mode: gun
grpc-service-name: vless-grpc
udp: true
_______________________________
Link Vless Account
_______________________________
Link TLS : vless://${uuid}@${domain}:443?path=/vless&security=tls&encryption=none&host=${domain}&type=ws&sni=${domain}#${user}
_______________________________
Link none TLS : vless://${uuid}@${domain}:80?path=/vless&security=none&encryption=none&host=${domain}&type=ws#${user}
_______________________________
Link GRPC : vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}
_______________________________
END
    if [ ${Quota} = '9999' ]; then
        TEXT="
◇━━━━━━━━━━━━━━━━━◇
Premium Vless Account
◇━━━━━━━━━━━━━━━━━◇
User         : ${user}
Domain       : <code>${domain}</code>
Login Limit  : ${iplim} IP
ISP          : ${ISP}
CITY         : ${CITY}
Port TLS     : 443
Port NTLS    : 80, 8080
Port GRPC    : 443
UUID         : <code>${uuid}</code>
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path vless   : <code>/vless</code>
ServiceName  : <code>/vless-grpc</code>
◇━━━━━━━━━━━━━━━━━◇
Link TLS     :
<code>${vless1}</code>
◇━━━━━━━━━━━━━━━━━◇
Link NTLS    :
<code>${vless2}</code>
◇━━━━━━━━━━━━━━━━━◇
Link gRPC    :
<code>${vless3}</code>
◇━━━━━━━━━━━━━━━━━◇
Format OpenClash :
http://$domain:89/vless-$user.txt
◇━━━━━━━━━━━━━━━━━◇
Expired Until    : $exp
◇━━━━━━━━━━━━━━━━━◇
$author
◇━━━━━━━━━━━━━━━━━◇
"
    else
        TEXT="
◇━━━━━━━━━━━━━━━━━◇
Premium Vless Account
◇━━━━━━━━━━━━━━━━━◇
User         : ${user}
Domain       : <code>${domain}</code>
Login Limit  : ${iplim} IP
Quota Limit  : ${Quota} GB
ISP          : ${ISP}
CITY         : ${CITY}
Port TLS     : 443
Port NTLS    : 80, 8080
Port GRPC    : 443
UUID         : <code>${uuid}</code>
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path vless   : <code>/vless</code>
ServiceName  : <code>/vless-grpc</code>
◇━━━━━━━━━━━━━━━━━◇
Link TLS     :
<code>${vless1}</code>
◇━━━━━━━━━━━━━━━━━◇
Link NTLS    :
<code>${vless2}</code>
◇━━━━━━━━━━━━━━━━━◇
Link GRPC    :
<code>${vless3}</code>
◇━━━━━━━━━━━━━━━━━◇
Format OpenClash :
http://$domain:89/vless-$user.txt
◇━━━━━━━━━━━━━━━━━◇
Expired Until    : $exp
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
        echo "$TEXT" >/etc/notiftele
        bash /etc/tele
    fi
    user2=$(echo "$user" | cut -c 1-3)
    TIME2=$(date +'%Y-%m-%d %H:%M:%S')
    TEXT2="
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<b>   PEMBELIAN VLESS SUCCES </b>
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<b>DOMAIN  :</b> <code>${domain} </code>
<b>CITY    :</b> <code>$CITY </code>
<b>DATE    :</b> <code>${TIME2} WIB </code>
<b>DETAIL  :</b> <code>Trx VLESS </code>
<b>USER    :</b> <code>${user2}xxx </code>
<b>IP      :</b> <code>${iplim} IP </code>
<b>DURASI  :</b> <code>$masaaktif Hari </code>
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<i>Notif Pembelian Akun Vless..</i>"
    curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
    clear
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}• Premium Vless Account •${NC} $COLOR1 $NC" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}User         ${COLOR1}: ${WH}${user}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}ISP          ${COLOR1}: ${WH}$ISP" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}City         ${COLOR1}: ${WH}$CITY" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}Domain       ${COLOR1}: ${WH}${domain}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}Login Limit  ${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/vless/akun/log-create-${user}.log
    if [ ${Quota} = '9999' ]; then
        echo -ne
    else
        echo -e "$COLOR1 ${NC} ${WH}Quota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/vless/akun/log-create-${user}.log
    fi
    echo -e "$COLOR1 ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}Port NTLS    ${COLOR1}: ${WH}80,8080" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}UUID         ${COLOR1}: ${WH}${uuid}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}Encryption   ${COLOR1}: ${WH}none" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}Network      ${COLOR1}: ${WH}ws" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}Path         ${COLOR1}: ${WH}/vless" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}Path grpc    ${COLOR1}: ${WH}/vless-grpc" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${COLOR1}Link Websocket TLS      ${WH}:${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}${vlesslink1}${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${COLOR1}Link Websocket NTLS  ${WH}:${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}${vlesslink2}${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${COLOR1}Link gRPC               ${WH}:${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}${vlesslink3}${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}Format Openclash ${COLOR1}: " | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}http://$domain:89/vless-$user.txt${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}Expired Until   ${COLOR1}: ${WH}$exp" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}    $author    " | tee -a /etc/vless/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
    echo "" | tee -a /etc/vless/akun/log-create-${user}.log
    systemctl restart xray >/dev/null 2>&1
    read -n 1 -s -r -p "Press any key to back on menu"
}
add-vless