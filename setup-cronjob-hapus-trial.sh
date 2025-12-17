#!/bin/bash

# Script untuk setup cronjob hapus trial users otomatis
# Akan dijalankan setiap hari pada jam 00:00 (tengah malam)

SCRIPT_PATH="/usr/bin/hapus-trial.sh"
CRON_FILE="/etc/cron.d/hapus-trial-auto"

echo "Setting up cronjob untuk hapus trial users..."

# Copy script ke /usr/bin jika belum ada
if [ ! -f "$SCRIPT_PATH" ]; then
    cp hapus-trial.sh "$SCRIPT_PATH"
    chmod +x "$SCRIPT_PATH"
    echo "✓ Script copied to $SCRIPT_PATH"
else
    echo "✓ Script already exists at $SCRIPT_PATH"
fi

# Buat cronjob file
cat > "$CRON_FILE" << EOF
# Cronjob untuk menghapus semua trial users setiap hari
# Dijalankan setiap hari jam 00:00 (tengah malam)
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0 0 * * * root /bin/bash $SCRIPT_PATH >/dev/null 2>&1
EOF

chmod 644 "$CRON_FILE"

echo "✓ Cronjob created at $CRON_FILE"
echo ""
echo "Cronjob Details:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Schedule : Setiap hari jam 00:00 (tengah malam)"
echo "Script   : $SCRIPT_PATH"
echo "Action   : Hapus semua trial users (SSH, VLESS, VMESS)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Untuk mengubah jadwal, edit file: $CRON_FILE"
echo ""
echo "Format cronjob:"
echo "  0 0 * * *  = Setiap hari jam 00:00"
echo "  0 */6 * * * = Setiap 6 jam"
echo "  0 12 * * * = Setiap hari jam 12:00"
echo ""
echo "Setup selesai!"
