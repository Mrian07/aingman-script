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

function delete_all_expired_users() {
    clear
    echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1│${NC}         ${WH}• DELETE ALL EXPIRED USERS •            ${NC}$COLOR1│${NC}"
    echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
    echo -e " "

    total_deleted=0
    ssh_deleted=0
    vless_deleted=0
    vmess_deleted=0
    trojan_deleted=0
    ssh_users=""
    vless_users=""
    vmess_users=""
    trojan_users=""

    today=$(date +%Y-%m-%d)
    current_user=$(whoami)

    # Dapatkan daftar user yang sedang login via SSH
    logged_users=$(who | awk '{print $1}' | sort -u)

    echo -e "${WH}[1/4] Menghapus expired SSH/OVPN users...${NC}"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -f /etc/xray/ssh ]; then
        while IFS= read -r line; do
            if [[ $line =~ ^###\ (.*)\ (.*)\ (.*)$ ]]; then
                user="${BASH_REMATCH[1]}"
                exp="${BASH_REMATCH[2]}"
                pass="${BASH_REMATCH[3]}"

                # Hanya proses user dengan prefix premium_ atau trial-
                if [[ ! "$user" =~ ^(premium_|trial-) ]]; then
                    continue
                fi

                # Skip jika user sedang login atau user penting
                if echo "$logged_users" | grep -q "^${user}$" || [[ "$user" == "root" ]] || [[ "$user" == "$current_user" ]]; then
                    echo "  ⚠ SSH User $user sedang login, dilewati"
                    continue
                fi

                exp_date=$(date -d "$exp" +%Y-%m-%d 2>/dev/null)
                if [[ "$exp_date" < "$today" ]]; then
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
                    rm /etc/cron.d/trialssh${user} >/dev/null 2>&1

                    ssh_deleted=$((ssh_deleted + 1))
                    ssh_users="$ssh_users$user, "
                    echo "  ✓ SSH User $user (expired: $exp) dihapus"
                fi
            fi
        done < <(grep -E "^###" "/etc/xray/ssh" 2>/dev/null)

        if [[ $ssh_deleted -gt 0 ]]; then
            systemctl restart sshd >/dev/null 2>&1
            systemctl restart ws-stunnel >/dev/null 2>&1
            systemctl restart ws-dropbear >/dev/null 2>&1
            systemctl restart ws-ovpn >/dev/null 2>&1
            echo -e "${WH}Total SSH/OVPN: $ssh_deleted users${NC}"
        else
            echo -e "  ${RED}Tidak ada expired SSH user${NC}"
        fi
    else
        echo -e "  ${RED}File SSH tidak ditemukan${NC}"
    fi

    echo -e " "
    echo -e "${WH}[2/4] Menghapus expired VLESS users...${NC}"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -f /etc/xray/config.json ]; then
        while IFS= read -r line; do
            if [[ $line =~ ^#vl\ (.*)\ (.*)\ (.*)$ ]]; then
                user="${BASH_REMATCH[1]}"
                exp="${BASH_REMATCH[2]}"
                uuid="${BASH_REMATCH[3]}"

                # Hanya proses user dengan prefix premium_ atau trial-
                if [[ ! "$user" =~ ^(premium_|trial-) ]]; then
                    continue
                fi

                exp_date=$(date -d "$exp" +%Y-%m-%d 2>/dev/null)
                if [[ "$exp_date" < "$today" ]]; then
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
                    echo "  ✓ VLESS User $user (expired: $exp) dihapus"
                fi
            fi
        done < <(grep -E "^#vl" "/etc/xray/config.json" 2>/dev/null)

        if [[ $vless_deleted -gt 0 ]]; then
            echo -e "${WH}Total VLESS: $vless_deleted users${NC}"
        else
            echo -e "  ${RED}Tidak ada expired VLESS user${NC}"
        fi
    else
        echo -e "  ${RED}File config.json tidak ditemukan${NC}"
    fi

    echo -e " "
    echo -e "${WH}[3/4] Menghapus expired VMESS users...${NC}"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -f /etc/xray/config.json ]; then
        while IFS= read -r line; do
            if [[ $line =~ ^#vmg\ (.*)\ (.*)\ (.*)$ ]]; then
                user="${BASH_REMATCH[1]}"
                exp="${BASH_REMATCH[2]}"
                uuid="${BASH_REMATCH[3]}"

                # Hanya proses user dengan prefix premium_ atau trial-
                if [[ ! "$user" =~ ^(premium_|trial-) ]]; then
                    continue
                fi

                exp_date=$(date -d "$exp" +%Y-%m-%d 2>/dev/null)
                if [[ "$exp_date" < "$today" ]]; then
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

                    vmess_deleted=$((vmess_deleted + 1))
                    vmess_users="$vmess_users$user, "
                    echo "  ✓ VMESS User $user (expired: $exp) dihapus"
                fi
            fi
        done < <(grep -E "^#vmg" "/etc/xray/config.json" 2>/dev/null)

        if [[ $vmess_deleted -gt 0 ]]; then
            echo -e "${WH}Total VMESS: $vmess_deleted users${NC}"
        else
            echo -e "  ${RED}Tidak ada expired VMESS user${NC}"
        fi
    fi

    echo -e " "
    echo -e "${WH}[4/4] Menghapus expired TROJAN users...${NC}"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ -f /etc/xray/config.json ]; then
        while IFS= read -r line; do
            if [[ $line =~ ^#trg\ (.*)\ (.*)\ (.*)$ ]]; then
                user="${BASH_REMATCH[1]}"
                exp="${BASH_REMATCH[2]}"
                uuid="${BASH_REMATCH[3]}"

                # Hanya proses user dengan prefix premium_ atau trial-
                if [[ ! "$user" =~ ^(premium_|trial-) ]]; then
                    continue
                fi

                exp_date=$(date -d "$exp" +%Y-%m-%d 2>/dev/null)
                if [[ "$exp_date" < "$today" ]]; then
                    if [ ! -e /etc/trojan/akundelete ]; then
                        echo "" >/etc/trojan/akundelete
                    fi
                    echo "### $user $exp $uuid" >>/etc/trojan/akundelete
                    sed -i "/^#trg $user $exp/,/^},{/d" /etc/xray/config.json
                    sed -i "/^#tr $user $exp/,/^},{/d" /etc/xray/config.json

                    rm /home/vps/public_html/trojan-$user.txt >/dev/null 2>&1
                    rm /etc/trojan/${user}IP >/dev/null 2>&1
                    rm /etc/trojan/${user}login >/dev/null 2>&1
                    rm /etc/trojan/akun/log-create-${user}.log >/dev/null 2>&1
                    rm /etc/cron.d/trialtrojan${user} >/dev/null 2>&1

                    trojan_deleted=$((trojan_deleted + 1))
                    trojan_users="$trojan_users$user, "
                    echo "  ✓ TROJAN User $user (expired: $exp) dihapus"
                fi
            fi
        done < <(grep -E "^#trg" "/etc/xray/config.json" 2>/dev/null)

        if [[ $trojan_deleted -gt 0 ]]; then
            echo -e "${WH}Total TROJAN: $trojan_deleted users${NC}"
        else
            echo -e "  ${RED}Tidak ada expired TROJAN user${NC}"
        fi
    fi

    if [[ $vless_deleted -gt 0 ]] || [[ $vmess_deleted -gt 0 ]] || [[ $trojan_deleted -gt 0 ]]; then
        systemctl restart xray >/dev/null 2>&1
    fi

    total_deleted=$((ssh_deleted + vless_deleted + vmess_deleted + trojan_deleted))

    ssh_users=${ssh_users%, }
    vless_users=${vless_users%, }
    vmess_users=${vmess_users%, }
    trojan_users=${trojan_users%, }

    echo -e " "
    echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
    echo -e "$COLOR1│${NC}              ${WH}• RINGKASAN PENGHAPUSAN •           ${NC}$COLOR1│${NC}"
    echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
    echo -e "${WH}SSH/OVPN : $ssh_deleted users${NC}"
    echo -e "${WH}VLESS    : $vless_deleted users${NC}"
    echo -e "${WH}VMESS    : $vmess_deleted users${NC}"
    echo -e "${WH}TROJAN   : $trojan_deleted users${NC}"
    echo -e "$COLOR1━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WH}TOTAL    : $total_deleted users dihapus${NC}"
    echo -e " "

    if [[ $total_deleted -gt 0 ]]; then
        TEXT="
<code>◇━━━━━━━━━━━━━━◇</code>
<b>  DELETE ALL EXPIRED USERS</b>
<code>◇━━━━━━━━━━━━━━◇</code>
<b>DOMAIN   :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>SSH      :</b> <code>$ssh_deleted users</code>
<b>VLESS    :</b> <code>$vless_deleted users</code>
<b>VMESS    :</b> <code>$vmess_deleted users</code>
<b>TROJAN   :</b> <code>$trojan_deleted users</code>
<b>TOTAL    :</b> <code>$total_deleted users</code>
<code>◇━━━━━━━━━━━━━━◇</code>
<i>All Expired Users Deleted Successfully...</i>
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

delete_all_expired_users
