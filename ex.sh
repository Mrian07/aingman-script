#!/bin/bash
rm trial*
cd
echo 1 > /proc/sys/vm/drop_caches
data=( `cat /etc/xray/ssh | grep '^###' | cut -d ' ' -f 2 | sort | uniq`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
pass=$(grep -w "^### $user" "/etc/xray/ssh" | cut -d ' ' -f 4 | sort | uniq)
exp=$(grep -w "^### $user" "/etc/xray/ssh" | cut -d ' ' -f 3 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" -le "0" ]]; then
sed -i "/^### $user $exp $pass/d" /etc/xray/ssh
if getent passwd $user > /dev/null 2>&1; then
userdel $user > /dev/null 2>&1
fi
rm /home/vps/public_html/ssh-$user.txt >/dev/null 2>&1
rm /etc/xray/sshx/${user}IP >/dev/null 2>&1
rm /etc/xray/sshx/${user}login >/dev/null 2>&1
fi
done
data=( `cat /etc/xray/noob | grep '^###' | cut -d ' ' -f 2 | sort | uniq`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^### $user" "/etc/xray/noob" | cut -d ' ' -f 3 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" -le "0" ]]; then
sed -i "/^### $user $exp/,/^},{/d" /etc/xray/noob
noobzvpns --remove-user "$user"
fi
done
data=( `cat /etc/xray/config.json | grep '^#vmg' | cut -d ' ' -f 2 | sort | uniq`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^#vmg $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
uuid=$(grep -w "^#vmg $user" "/etc/xray/config.json" | cut -d ' ' -f 4 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" -le "0" ]]; then
if [ ! -e /etc/vmess/akundelete ]; then
echo "" > /etc/vmess/akundelete
fi
clear
echo "### $user $exp $uuid" >> /etc/vmess/akundelete
sed -i "/^#vmg $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#vm $user $exp/,/^},{/d" /etc/xray/config.json
rm -f /etc/xray/$user-tls.json /etc/xray/$user-none.json
rm /home/vps/public_html/vmess-$user.txt >/dev/null 2>&1
rm /etc/vmess/${user}IP >/dev/null 2>&1
rm /etc/vmess/${user}login >/dev/null 2>&1
fi
done
data=( `cat /etc/xray/config.json | grep '^#vlg' | cut -d ' ' -f 2 | sort | uniq`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^#vlg $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
uuid=$(grep -w "^#vlg $user" "/etc/xray/config.json" | cut -d ' ' -f 4 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" -le "0" ]]; then
if [ ! -e /etc/vless/akundelete ]; then
echo "" > /etc/vless/akundelete
fi
clear
echo "### $user $exp $uuid" >> /etc/vless/akundelete
sed -i "/^#vlg $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#vl $user $exp/,/^},{/d" /etc/xray/config.json
rm /home/vps/public_html/vless-$user.txt >/dev/null 2>&1
rm /etc/vless/${user}IP >/dev/null 2>&1
rm /etc/vless/${user}login >/dev/null 2>&1
fi
done
data=( `cat /etc/xray/config.json | grep '^#trg' | cut -d ' ' -f 2 | sort | uniq`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^#trg $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
uuid=$(grep -w "^#trg $user" "/etc/xray/config.json" | cut -d ' ' -f 4 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" -le "0" ]]; then
if [ ! -e /etc/trojan/akundelete ]; then
echo "" > /etc/trojan/akundelete
fi
clear
echo "### $user $exp $uuid" >> /etc/trojan/akundelete
sed -i "/^#tr $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#trg $user $exp/,/^},{/d" /etc/xray/config.json
rm /home/vps/public_html/trojan-$user.txt >/dev/null 2>&1
rm /etc/trojan/${user}IP >/dev/null 2>&1
rm /etc/trojan/${user}login >/dev/null 2>&1
fi
done
systemctl restart xray
data=( `cat /etc/xray/config.json | grep '^#ssg' | cut -d ' ' -f 2 | sort | uniq`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^#ssg $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" -le "0" ]]; then
sed -i "/^#ssg $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#ssg $user $exp/,/^},{/d" /etc/xray/config.json
fi
done
systemctl restart xray
data=( `cat /etc/xray/config.json | grep '^#ss' | cut -d ' ' -f 2 | sort | uniq`);
now=`date +"%Y-%m-%d"`
for user in "${data[@]}"
do
exp=$(grep -w "^#ss $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
if [[ "$exp2" -le "0" ]]; then
sed -i "/^#ss $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#ss $user $exp/,/^},{/d" /etc/xray/config.json
fi
done
systemctl restart xray

# Delete expired ZIVPN users
ZIVPN_DIR="/etc/zivpn"
ZIVPN_USERS="$ZIVPN_DIR/users.txt"
ZIVPN_CONFIG="$ZIVPN_DIR/config.json"

if [ -f "$ZIVPN_USERS" ]; then
    data=( `cat $ZIVPN_USERS | grep '^###' | cut -d ' ' -f 2 | sort | uniq`);
    now=`date +"%Y-%m-%d"`
    now_timestamp=$(date -d "$now" +%s)
    temp_file=$(mktemp)
    zivpn_updated=0
    
    # Copy non-user lines first
    grep -v '^###' $ZIVPN_USERS > $temp_file 2>/dev/null
    
    for user in "${data[@]}"
    do
        exp=$(grep -w "^### $user" "$ZIVPN_USERS" | cut -d ' ' -f 3 | sort | uniq)
        pass=$(grep -w "^### $user" "$ZIVPN_USERS" | cut -d ' ' -f 4 | sort | uniq)
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        exp2=$(( (d1 - d2) / 86400 ))
        
        if [[ "$exp2" -le "0" ]]; then
            # User expired, delete files
            rm -f /etc/zivpn/${user}IP >/dev/null 2>&1
            rm -f /home/vps/public_html/zivpn-${user}.txt >/dev/null 2>&1
            rm -f /etc/zivpn/akun/log-create-${user}.log >/dev/null 2>&1
            rm -f /etc/cron.d/trialzivpn${user} >/dev/null 2>&1
            zivpn_updated=1
        else
            # User not expired, keep in file
            echo "### $user $exp $pass" >> $temp_file
        fi
    done
    
    # Replace original file
    mv $temp_file $ZIVPN_USERS
    
    # Update config.json and restart service if needed
    if [[ $zivpn_updated -eq 1 ]]; then
        if command -v jq &> /dev/null && [ -f "$ZIVPN_CONFIG" ]; then
            passwords_array="[\"zi\""
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
            systemctl restart zivpn >/dev/null 2>&1
        fi
    fi
fi

hariini=`date +%d-%m-%Y`
cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/expirelist.txt
totalaccounts=`cat /tmp/expirelist.txt | wc -l`
for((i=1; i<=$totalaccounts; i++ ))
do
tuserval=`head -n $i /tmp/expirelist.txt | tail -n 1`
username=`echo $tuserval | cut -f1 -d:`
userexp=`echo $tuserval | cut -f2 -d:`
userexpireinseconds=$(( $userexp * 86400 ))
tglexp=`date -d @$userexpireinseconds`
tgl=`echo $tglexp |awk -F" " '{print $3}'`
while [ ${#tgl} -lt 2 ]
do
tgl="0"$tgl
done
while [ ${#username} -lt 15 ]
do
username=$username" "
done
bulantahun=`echo $tglexp |awk -F" " '{print $2,$6}'`
todaystime=`date +%s`
if [ $userexpireinseconds -ge $todaystime ] ;
then
:
else
userdel --force $username
fi
done
