#!/bin/bash

biji=$(date +"%Y-%m-%d" -d "$dateFromServer")
colornow=$(cat /etc/rmbl/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2 | sed 's/ //g')"
COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2 | sed 's/ //g')"
WH='\033[1;37m'
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

function delete_all_trial_users() {
    clear
    echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1│${NC}         ${WH}• DELETE ALL TRIAL USERS •              ${NC}$COLOR1│${NC}"
    echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
    echo -e " "

    total_deleted=0
    ssh_deleted=0
    vless_deleted=0
    vmess_deleted=0
    ssh_users=""
    vless_users=""
    vmess_users=""

    echo -e "${WH}[1/3] Menghapus trial SSH/OVPN users...${NC}"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    trial_ssh_count=$(grep -E "^### trial-" "/etc/xray/ssh" 2>/dev/null | wc -l)

    if [[ $trial_ssh_count -gt 0 ]]; then
        while IFS= read -r line; do
            if [[ $line =~ ^###\ (trial-.*)\ (.*)\ (.*)$ ]]; then
                user="${BASH_REMATCH[1]}"
                exp="${BASH_REMATCH[2]}"
                pass="${BASH_REMATCH[3]}"

                ps aux | grep "sshd.*$user" | grep -v grep | awk '{print $2}' | xargs -r kill -9 >/dev/null 2>&1
                pkill -f "sshd.*$user" >/dev/null 2>&1
                ps -u "$user" -o pid= 2>/dev/null | xargs -r kill -9 >/dev/null 2>&1

                if getent passwd $user > /dev/null 2>&1; then
                    userdel -f $user > /dev/null 2>&1
                fi

                sed -i "/^### $user $exp $pass/d" /etc/xray/ssh

                rm /home/vps/public_html/ssh-$user.txt >/dev/null 2>&1
                rm /etc/xray/sshx/${user}IP >/dev/null 2>&1
                rm /etc/xray/sshx/${user}login >/dev/null 2>&1
                rm /etc/xray/sshx/akun/log-create-${user}.log >/dev/null 2>&1

                at -l | grep delete_trial_${user} | awk '{print $1}' | xargs -r atrm >/dev/null 2>&1
                rm /tmp/delete_trial_${user}.sh >/dev/null 2>&1
                rm /etc/cron.d/trialssh${user} >/dev/null 2>&1

                ssh_deleted=$((ssh_deleted + 1))
                ssh_users="$ssh_users$user, "
                echo "  ✓ SSH User $user dihapus"
            fi
        done < <(grep -E "^### trial-" "/etc/xray/ssh" 2>/dev/null)

        systemctl restart sshd >/dev/null 2>&1
        systemctl restart ws-stunnel >/dev/null 2>&1
        systemctl restart ws-dropbear >/dev/null 2>&1
        systemctl restart ws-ovpn >/dev/null 2>&1

        echo -e "${WH}Total SSH/OVPN: $ssh_deleted users${NC}"
    else
        echo -e "  ${RED}Tidak ada trial SSH user${NC}"
    fi

    echo -e " "
    echo -e "${WH}[2/3] Menghapus trial VLESS users...${NC}"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    trial_vless_count=$(grep -E "^#vl trial-" "/etc/xray/config.json" 2>/dev/null | wc -l)

    if [[ $trial_vless_count -gt 0 ]]; then
        while IFS= read -r line; do
            if [[ $line =~ ^#vl\ (trial-.*)\ (.*)\ (.*)$ ]]; then
                user="${BASH_REMATCH[1]}"
                exp="${BASH_REMATCH[2]}"
                uuid="${BASH_REMATCH[3]}"

                if [ ! -e /etc/vless/akundelete ]; then
                    echo "" >/etc/vless/akundelete
                fi
                echo "### $user $exp $uuid" >>/etc/vless/akundelete
                sed -i "/^#vl $user $exp/,/^},{/d" /etc/xray/config.json
                sed -i "/^#vlg $user $exp/,/^},{/d" /etc/xray/config.json

                rm /etc/vless/${user}IP >/dev/null 2>&1
                rm /home/vps/public_html/vless-$user.txt >/dev/null 2>&1
                rm /etc/vless/${user}login >/dev/null 2>&1
                rm /etc/vless/akun/log-create-${user}.log >/dev/null 2>&1
                rm /etc/cron.d/trialvless${user} >/dev/null 2>&1

                vless_deleted=$((vless_deleted + 1))
                vless_users="$vless_users$user, "
                echo "  ✓ VLESS User $user dihapus"
            fi
        done < <(grep -E "^#vl trial-" "/etc/xray/config.json" 2>/dev/null)

        echo -e "${WH}Total VLESS: $vless_deleted users${NC}"
    else
        echo -e "  ${RED}Tidak ada trial VLESS user${NC}"
    fi

    echo -e " "
    echo -e "${WH}[3/3] Menghapus trial VMESS users...${NC}"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    trial_vmess_count=$(grep -E "^#vmg trial-" "/etc/xray/config.json" 2>/dev/null | wc -l)

    if [[ $trial_vmess_count -gt 0 ]]; then
        while IFS= read -r line; do
            if [[ $line =~ ^#vmg\ (trial-.*)\ (.*)\ (.*)$ ]]; then
                user="${BASH_REMATCH[1]}"
                exp="${BASH_REMATCH[2]}"
                uuid="${BASH_REMATCH[3]}"

                if [ ! -e /etc/vmess/akundelete ]; then
                    echo "" >/etc/vmess/akundelete
                fi
                echo "### $user $exp $uuid" >>/etc/vmess/akundelete
                sed -i "/^#vmg $user $exp/,/^},{/d" /etc/xray/config.json
                sed -i "/^#vm $user $exp/,/^},{/d" /etc/xray/config.json

                rm /home/vps/public_html/vmess-$user.txt >/dev/null 2>&1
                rm /etc/vmess/${user}IP >/dev/null 2>&1
                rm /etc/vmess/${user}login >/dev/null 2>&1
                rm /etc/vmess/akun/log-create-${user}.log >/dev/null 2>&1
                rm /etc/cron.d/trialvmess${user} >/dev/null 2>&1

                at -l | grep delete_trial_${user} | awk '{print $1}' | xargs -r atrm >/dev/null 2>&1
                rm /tmp/delete_trial_${user}.sh >/dev/null 2>&1

                vmess_deleted=$((vmess_deleted + 1))
                vmess_users="$vmess_users$user, "
                echo "  ✓ VMESS User $user dihapus"
            fi
        done < <(grep -E "^#vmg trial-" "/etc/xray/config.json" 2>/dev/null)

        echo -e "${WH}Total VMESS: $vmess_deleted users${NC}"
    else
        echo -e "  ${RED}Tidak ada trial VMESS user${NC}"
    fi

    systemctl restart xray >/dev/null 2>&1

    total_deleted=$((ssh_deleted + vless_deleted + vmess_deleted))

    ssh_users=${ssh_users%, }
    vless_users=${vless_users%, }
    vmess_users=${vmess_users%, }

    echo -e " "
    echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1│${NC}              ${WH}• RINGKASAN PENGHAPUSAN •           ${NC}$COLOR1│${NC}"
    echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
    echo -e "${WH}SSH/OVPN : $ssh_deleted users${NC}"
    echo -e "${WH}VLESS    : $vless_deleted users${NC}"
    echo -e "${WH}VMESS    : $vmess_deleted users${NC}"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WH}TOTAL    : $total_deleted users dihapus${NC}"
    echo -e " "

    if [[ $total_deleted -gt 0 ]]; then
        TEXT="
<code>◇━━━━━━━━━━━━━━◇</code>
<b>  DELETE ALL TRIAL USERS</b>
<code>◇━━━━━━━━━━━━━━◇</code>
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>SSH      :</b> <code>$ssh_deleted users</code>
<b>VLESS    :</b> <code>$vless_deleted users</code>
<b>VMESS    :</b> <code>$vmess_deleted users</code>
<b>TOTAL    :</b> <code>$total_deleted users</code>
<code>◇━━━━━━━━━━━━━━◇</code>
<i>All Trial Users Deleted Successfully...</i>
"
        curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null

        if [ -e /etc/tele ]; then
            echo "$TEXT" >/etc/notiftele
            bash /etc/tele
        fi
    fi

    read -n 1 -s -r -p "Press any key to back on menu"
    menu
}

delete_all_trial_users
