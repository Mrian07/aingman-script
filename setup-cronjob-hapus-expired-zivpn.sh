#!/bin/bash
# Setup Crontab for Auto Delete Expired ZIVPN Accounts

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup Auto Delete Expired ZIVPN${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if hapus-expired-zivpn.sh exists
if [ ! -f /usr/bin/hapus-expired-zivpn ]; then
    echo -e "${YELLOW}Installing hapus-expired-zivpn script...${NC}"
    
    # Copy script to /usr/bin
    if [ -f ./hapus-expired-zivpn.sh ]; then
        cp ./hapus-expired-zivpn.sh /usr/bin/hapus-expired-zivpn
        chmod +x /usr/bin/hapus-expired-zivpn
        echo -e "${GREEN}✓ Script installed to /usr/bin/hapus-expired-zivpn${NC}"
    else
        echo -e "${RED}✗ Error: hapus-expired-zivpn.sh not found!${NC}"
        exit 1
    fi
fi

# Create crontab entry
CRON_FILE="/etc/cron.d/hapus-expired-zivpn"

echo -e "${YELLOW}Creating crontab entry...${NC}"

cat > $CRON_FILE << EOF
# Auto Delete Expired ZIVPN Accounts
# Run every day at 00:00 (midnight)
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Daily cleanup at midnight
0 0 * * * root /usr/bin/hapus-expired-zivpn >> /var/log/zivpn-cleanup.log 2>&1

# Optional: Run every 6 hours (uncomment if needed)
# 0 */6 * * * root /usr/bin/hapus-expired-zivpn >> /var/log/zivpn-cleanup.log 2>&1

# Optional: Run every hour (uncomment if needed)
# 0 * * * * root /usr/bin/hapus-expired-zivpn >> /var/log/zivpn-cleanup.log 2>&1
EOF

chmod 644 $CRON_FILE

echo -e "${GREEN}✓ Crontab created: $CRON_FILE${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Configuration Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Script Location : ${YELLOW}/usr/bin/hapus-expired-zivpn${NC}"
echo -e "Crontab File    : ${YELLOW}$CRON_FILE${NC}"
echo -e "Log File        : ${YELLOW}/var/log/zivpn-cleanup.log${NC}"
echo -e "Schedule        : ${YELLOW}Daily at 00:00 (midnight)${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Manual Commands${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Run manually    : ${YELLOW}hapus-expired-zivpn${NC}"
echo -e "View log        : ${YELLOW}tail -f /var/log/zivpn-cleanup.log${NC}"
echo -e "Edit crontab    : ${YELLOW}nano $CRON_FILE${NC}"
echo -e "Disable crontab : ${YELLOW}rm $CRON_FILE${NC}"
echo ""
echo -e "${GREEN}✓ Setup completed successfully!${NC}"
echo ""

# Ask if user wants to run test
read -p "Do you want to run a test now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Running test...${NC}"
    /usr/bin/hapus-expired-zivpn
    echo ""
    echo -e "${GREEN}✓ Test completed!${NC}"
fi

exit 0
