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
if [ ! -e /etc/vmess/akun ]; then
    mkdir -p /etc/vmess/akun
fi
function add-vmess() {
    clear
    until [[ $user =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
        echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
        echo -e "$COLOR1│${NC} ${COLBG1}            ${WH}• Add Vmess Account •              ${NC} $COLOR1│ $NC"
        echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
        echo -e ""
        read -rp "  Username    : " -e user
        CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)
        if [[ ${CLIENT_EXISTS} == '1' ]]; then
            clear
            echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
            echo -e "$COLOR1│ ${NC} ${COLBG1}            ${WH}• Add Vmess Account •             ${NC} $COLOR1│ $NC"
            echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
            echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
            echo -e "$COLOR1│                                                 │"
            echo -e "$COLOR1│${WH} Nama Duplikat Silahkan Buat Nama Lain.          $COLOR1│"
            echo -e "$COLOR1│                                                 │"
            echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
            read -n 1 -s -r -p "Press any key to back"
            add-vmess
        fi
    done
    exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
    until [[ $iplim =~ ^[0-9]+$ ]]; do
        read -p "  Limit User  : " iplim
    done
    until [[ $Quota =~ ^[0-9]+$ ]]; do
        read -p "  Limit Quota : " Quota
    done
    uuid=$(cat /proc/sys/kernel/random/uuid)
    until [[ $masaaktif =~ ^[0-9]+$ ]]; do
        read -p "  Masa Aktif  : " masaaktif
    done
    if [ ! -e /etc/vmess ]; then
        mkdir -p /etc/vmess
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
        echo "${d}" >/etc/vmess/${user}
    fi
    echo "${iplim}" >/etc/vmess/${user}IP
    exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
    sed -i '/#vmess$/a\#vm '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
    sed -i '/#vmessgrpc$/a\#vmg '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
    asu=$(cat <<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vmess",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF
    )
    ask=$(cat <<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vmess",
"type": "none",
"host": "${domain}",
"tls": "none"
}
EOF
    )
    grpc=$(cat <<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "grpc",
"path": "vmess-grpc",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF
    )
    vmess_base641=$(base64 -w 0 <<<$vmess_json1)
    vmess_base642=$(base64 -w 0 <<<$vmess_json2)
    vmess_base643=$(base64 -w 0 <<<$vmess_json3)
    vmesslink1="vmess://$(echo $asu | base64 -w 0)"
    vmesslink2="vmess://$(echo $ask | base64 -w 0)"
    vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
    VMESS_WS=$(cat <<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vmess",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF
    )
    VMESS_NON_TLS=$(cat <<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vmess",
"type": "none",
"host": "${domain}",
"tls": "none"
}
EOF
    )
    VMESS_GRPC=$(cat <<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "grpc",
"path": "/vmess-grpc",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF
    )
    VMESS_OPOK=$(cat <<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "http://tsel.me/worryfree",
"type": "none",
"host": "tsel.me",
"tls": "none"
}
EOF
    )
    cat >/home/vps/public_html/vmess-$user.txt <<-END
_______________________________________________________
Format Vmess WS (CDN)
_______________________________________________________
- name: vmess-$user-WS (CDN)
type: vmess
server: ${domain}
port: 443
uuid: ${uuid}
alterId: 0
cipher: auto
udp: true
tls: true
skip-cert-verify: true
servername: ${domain}
network: ws
ws-opts:
path: /vmess
headers:
Host: ${domain}
_______________________________________________________
Format Vmess WS (CDN) Non TLS
_______________________________________________________
- name: vmess-$user-WS (CDN) Non TLS
type: vmess
server: ${domain}
port: 80
uuid: ${uuid}
alterId: 0
cipher: auto
udp: true
tls: false
skip-cert-verify: false
servername: ${domain}
network: ws
ws-opts:
path: /vmess
headers:
Host: ${domain}
_______________________________________________________
Format Vmess gRPC (SNI)
_______________________________________________________
- name: vmess-$user-gRPC (SNI)
server: ${domain}
port: 443
type: vmess
uuid: ${uuid}
alterId: 0
cipher: auto
network: grpc
tls: true
servername: ${domain}
skip-cert-verify: true
grpc-opts:
grpc-service-name: vmess-grpc
_______________________________________________________
Format Vmess WS (CDN) Non TLS Opok TSEL
_______________________________________________________
- name: vmess-$user-WS (CDN) Non TLS
type: vmess
server: ${domain}
port: 80
uuid: ${uuid}
alterId: 0
cipher: auto
udp: true
tls: false
skip-cert-verify: true
servername: comunity.instagram.com
network: ws
ws-opts:
path: : http://tsel.me/worryfree
headers:
Host: ${domain}
_______________________________________________________
Link Vmess Account
_______________________________________________________
Link TLS : vmess://$(echo $VMESS_WS | base64 -w 0)
_______________________________________________________
Link NTLS : vmess://$(echo $VMESS_NON_TLS | base64 -w 0)
_______________________________________________________
Link gRPC : vmess://$(echo $VMESS_GRPC | base64 -w 0)
_______________________________________________________
Link Opok : vmess://$(echo $VMESS_OPOK | base64 -w 0)
_______________________________________________________
END
    if [ ${Quota} = '9999' ]; then
        TEXT="
◇━━━━━━━━━━━━━━━━━◇
Premium Vmess Account
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
Path         : <code>/vmess</code>
Path Support : <code>https://bug.com/vmess</code>
ServiceName  : <code>vmess-grpc</code>
◇━━━━━━━━━━━━━━━━━◇
Link TLS     :
<code>${vmesslink1}</code>
◇━━━━━━━━━━━━━━━━━◇
Link NTLS    :
<code>${vmesslink2}</code>
◇━━━━━━━━━━━━━━━━━◇
Link GRPC    :
<code>${vmesslink3}</code>
◇━━━━━━━━━━━━━━━━━◇
Format OpenClash :
http://$domain:89/vmess-$user.txt
◇━━━━━━━━━━━━━━━━━◇
Expired Until    : $exp
◇━━━━━━━━━━━━━━━━━◇
$author
◇━━━━━━━━━━━━━━━━━◇
"
    else
        TEXT="
◇━━━━━━━━━━━━━━━━━◇
Premium Vmess Account
◇━━━━━━━━━━━━━━━━━◇
User         : ${user}
Domain       : <code>${domain}</code>
Login Limit  : ${iplim} IP
Quota Limit  : ${Quota} GB
ISP          : ${ISP}
CITY         : ${CITY}
Expired On   : $exp
Port TLS     : 443
Port NTLS    : 80, 8080
Port GRPC    : 443
UUID         : <code>${uuid}</code>
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path         : <code>/vmess</code>
Path Support : <code>https://bug.com/vmess</code>
ServiceName  : <code>vmess-grpc</code>
◇━━━━━━━━━━━━━━━━━◇
Link TLS     :
<code>${vmesslink1}</code>
◇━━━━━━━━━━━━━━━━━◇
Link NTLS    :
<code>${vmesslink2}</code>
◇━━━━━━━━━━━━━━━━━◇
Link GRPC    :
<code>${vmesslink3}</code>
◇━━━━━━━━━━━━━━━━━◇
Format OpenClash :
http://$domain:89/vmess-$user.txt
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
<b>   PEMBELIAN VMESS SUCCES </b>
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<b>DOMAIN  :</b> <code>${domain} </code>
<b>CITY    :</b> <code>$CITY </code>
<b>DATE    :</b> <code>${TIME2} WIB </code>
<b>DETAIL  :</b> <code>Trx VMESS </code>
<b>USER    :</b> <code>${user2}xxx </code>
<b>IP      :</b> <code>${iplim} IP </code>
<b>DURASI  :</b> <code>$masaaktif Hari </code>
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<i>Notif Pembelian Akun Vmess..</i>"
    curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
    clear
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}• Premium Vmess Account • ${NC} $COLOR1 $NC" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Username ${COLOR1}: ${WH}${user}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}ISP  ${COLOR1}: ${WH}$ISP" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}City ${COLOR1}: ${WH}$CITY" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Domain  ${COLOR1}: ${WH}${domain}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Limit IP${COLOR1}: ${WH}${iplim} User" | tee -a /etc/vmess/akun/log-create-${user}.log
    if [ ${Quota} = '9999' ]; then
        echo -ne
    else
        echo -e "$COLOR1${NC}${WH}Quota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/vmess/akun/log-create-${user}.log
    fi
    echo -e "$COLOR1 ${NC} ${WH}Expired On ${COLOR1}: ${WH}$exp" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Port TLS      ${COLOR1}: ${WH}443" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Port NTLS    ${COLOR1}: ${WH}80,8080" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Port gRPC     ${COLOR1}: ${WH}443" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}UUID         ${COLOR1}: ${WH}${uuid}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}alterId       ${COLOR1}: ${WH}0" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Security      ${COLOR1}: ${WH}auto" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Network       ${COLOR1}: ${WH}ws" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Path          ${COLOR1}: ${WH}/vmess" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Path Support  ${COLOR1}: ${WH}http://bug/vmess" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}ServiceName   ${COLOR1}: ${WH}vmess-grpc" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${COLOR1}Link TLS  ${WH}:    ${vmesslink1}${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${COLOR1}Link NTLS ${WH}:    ${vmesslink2}${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${COLOR1}Link GRPC ${WH}:    ${vmesslink3}${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}Format Openclash ${COLOR1}:" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1${NC}${WH}http://$domain:89/vmess-$user.txt${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1 ${NC} ${WH}    $author     " | tee -a /etc/vmess/akun/log-create-${user}.log
    echo -e "$COLOR1 ◇━━━━━━━━━━━━━━━━━◇ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
    echo "" | tee -a /etc/vmess/akun/log-create-${user}.log
    systemctl restart xray >/dev/null 2>&1
    read -n 1 -s -r -p "Press any key to back on menu"
}
add-vmess