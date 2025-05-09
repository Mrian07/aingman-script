#!/bin/bash
# // PROJECT STORE

# Token AngIMAN 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
TOKEN="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"
today=`date -d "0 days" +"%Y-%m-%d"`
git clone https://github.com/AngIMAN/izin_jual.git /root/ipvps/ &> /dev/null
clear
echo -e ""
read -p "Input IP Address : " ip
CLIENT_EXISTS=$(grep -w $ip /root/ipvps/ip | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
echo "IP Already Exist !"
rm -rf /root/ipvps
exit 0
fi
echo -e ""
read -p " Input username : " name
echo -e ""
clear
read -p " Masukan waktu expired : " -e exp
exp2=`date -d "${exp} days" +"%Y-%m-%d"`
echo "### ${name} ${exp2} ${ip}" >> /root/ipvps/ip
cd /root/ipvps
git config --global user.email "ahmadardhiansyah2020@gmail.com" &> /dev/null
git config --global user.name "AngIMAN" &> /dev/null
rm -rf .git &> /dev/null
git init &> /dev/null
git add . &> /dev/null
git commit -m register &> /dev/null
git branch -M main &> /dev/null
git remote add origin https://github.com/AngIMAN/izin_jual
git push -f https://${TOKEN}@github.com/AngIMAN/izin_jual.git &> /dev/null
rm -rf /root/ipvps
clear
