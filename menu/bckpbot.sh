#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
colornow=$(cat /etc/rmbl/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
###########- END COLOR CODE -##########

clear
echo -e "${tyblue}┌──────────────────────────────────────────┐${NC}"
echo -e "${tyblue}         Please select a Bot type below                 ${NC}"
echo -e "${tyblue}└──────────────────────────────────────────┘${NC}"
echo -e "${tyblue}┌──────────────────────────────────────────┐${NC}"
echo -e "${tyblue}           [ 1 ]  Buat Database BOT                       ${NC}"
echo -e "${tyblue}           [ 2 ]  Tidak buat database BOT                   ${NC}"
echo -e "${tyblue}└──────────────────────────────────────────┘${NC}"
read -p "   Please select numbers 1-2 or Any Button(Random) to next : " bot
echo ""
if [[ $bot == "1" ]]; then
clear
rm -f /usr/bin/token
rm -f /usr/bin/idchat
echo -e "[ ${green}INFO${NC} ] Create for database"
read -rp "Enter Token (Creat on @BotFather) : " -e token2
echo "$token2" >> /usr/bin/token
read -rp "Enter Your Id (Creat on @userinfobot)  : " -e idchat
echo "$idchat" >> /usr/bin/idchat
sleep 1
bottelegram
elif [[ $bot == "2" ]]; then
bottelegram
fi
