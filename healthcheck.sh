#!/bin/bash
#
# healthcheck.sh — Server health monitor for projectofict171.com
#
# Checks five things and records the result with a timestamp:
#   1. Apache service     - and AUTO-RESTARTS it if it has stopped
#   2. Website response   - confirms the site returns HTTP 200
#   3. Disk usage         - warns above a threshold
#   4. Memory usage       - warns above a threshold
#   5. SSL certificate    - warns when expiry is near
#
# Author:  Sayeed Bin Akhter - 35820304 - ICT171, Murdoch University
# Licence: CC BY 4.0
#
# Usage:
#   chmod +x healthcheck.sh
#   sudo ./healthcheck.sh
#
# Schedule every 5 minutes (run: sudo crontab -e, then add the line below).
# The script logs to the file itself, so no redirection is needed:
#   */5 * * * * /home/azureuser/healthcheck.sh >/dev/null 2>&1

set -u

# ---- Configuration -------------------------------------------------------
DOMAIN="https://projectofict171.com"
CERT_DOMAIN="projectofict171.com"
SERVICE="apache2"
LOGFILE="/var/log/healthcheck.log"
DISK_WARN=80          # warn if disk usage is at or above this %
MEM_WARN=85           # warn if memory usage is at or above this %
CERT_WARN_DAYS=14     # warn if the certificate expires within this many days

# ---- Terminal colours (ignored when written to the log file) -------------
GREEN="\033[0;32m"; RED="\033[0;31m"; YELLOW="\033[0;33m"; RESET="\033[0m"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
STATUS="OK"

# ---- 1. Apache service (auto-restart if it has stopped) ------------------
if systemctl is-active --quiet "$SERVICE"; then
    APACHE_MSG="${SERVICE}: RUNNING"
else
    systemctl start "$SERVICE"
    if systemctl is-active --quiet "$SERVICE"; then
        APACHE_MSG="${SERVICE}: WAS DOWN, auto-restarted"
        STATUS="RECOVERED"
    else
        APACHE_MSG="${SERVICE}: FAILED to restart"
        STATUS="CRITICAL"
    fi
fi

# ---- 2. Website HTTP response --------------------------------------------
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" --max-time 10 "$DOMAIN")
if [ "$HTTP_CODE" = "200" ]; then
    WEB_MSG="Website: ONLINE (HTTP $HTTP_CODE)"
else
    WEB_MSG="Website: PROBLEM (HTTP $HTTP_CODE)"
    STATUS="CRITICAL"
fi

# ---- 3. Disk usage of the root filesystem --------------------------------
DISK_USE=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
DISK_MSG="Disk: ${DISK_USE}%"
if [ "$DISK_USE" -ge "$DISK_WARN" ]; then
    DISK_MSG="Disk: ${DISK_USE}% (HIGH)"
    [ "$STATUS" = "OK" ] && STATUS="WARN"
fi

# ---- 4. Memory usage -----------------------------------------------------
MEM_USE=$(free | awk '/Mem:/ {printf("%d", $3/$2*100)}')
MEM_MSG="Memory: ${MEM_USE}%"
if [ "$MEM_USE" -ge "$MEM_WARN" ]; then
    MEM_MSG="Memory: ${MEM_USE}% (HIGH)"
    [ "$STATUS" = "OK" ] && STATUS="WARN"
fi

# ---- 5. SSL certificate days remaining -----------------------------------
CERT_FILE="/etc/letsencrypt/live/${CERT_DOMAIN}/cert.pem"
if [ -f "$CERT_FILE" ]; then
    END_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
    DAYS_LEFT=$(( ( $(date -d "$END_DATE" +%s) - $(date +%s) ) / 86400 ))
    CERT_MSG="SSL: ${DAYS_LEFT} days left"
    if [ "$DAYS_LEFT" -le "$CERT_WARN_DAYS" ]; then
        CERT_MSG="SSL: ${DAYS_LEFT} days left (RENEW SOON)"
        [ "$STATUS" = "OK" ] && STATUS="WARN"
    fi
else
    CERT_MSG="SSL: certificate not found"
fi

# ---- Compose one line, log it, and print it ------------------------------
LINE="[$TIMESTAMP] [$STATUS] $APACHE_MSG | $WEB_MSG | $DISK_MSG | $MEM_MSG | $CERT_MSG"
echo "$LINE" >> "$LOGFILE"

case "$STATUS" in
    OK)        COLOUR=$GREEN ;;
    RECOVERED) COLOUR=$YELLOW ;;
    WARN)      COLOUR=$YELLOW ;;
    *)         COLOUR=$RED ;;
esac
echo -e "${COLOUR}${LINE}${RESET}"
