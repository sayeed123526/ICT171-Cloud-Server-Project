#!/bin/bash
# healthcheck.sh
# Checks if Apache is running and if the website responds.
# Author: Sayeed Bin Akhter — ICT171, Murdoch University

LOGFILE="/var/log/healthcheck.log"
DOMAIN="https://projectofict171.com"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if systemctl is-active --quiet apache2; then
    APACHE_STATUS="Apache2: RUNNING"
else
    APACHE_STATUS="Apache2: STOPPED"
fi

HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" $DOMAIN)

if [ "$HTTP_CODE" == "200" ]; then
    WEB_STATUS="Website: ONLINE (HTTP $HTTP_CODE)"
else
    WEB_STATUS="Website: PROBLEM (HTTP $HTTP_CODE)"
fi

echo "[$TIMESTAMP] $APACHE_STATUS | $WEB_STATUS" >> $LOGFILE
echo "[$TIMESTAMP] $APACHE_STATUS | $WEB_STATUS"
