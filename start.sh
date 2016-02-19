#!/bin/bash

## setup
# soft link /etc/letsencrypt locally from /srv/ volume mount
ln -s /srv/etc/letsencrypt /etc/letsencrypt
source /etc/cert-renew-config-secret/env

# Add a cron line with details of the current user etc
minute=$(echo $RANDOM % 60 | bc)
hour=$(echo $RANDOM % 23 | bc)
day=$(echo $RANDOM % 27 + 1 | bc)

CRON_FREQUENCY=${CRON_FREQUENCY:-"$minute $hour $day * *"}

echo "Configuring cron..."
echo "DOMAINS: " $DOMAINS
echo "EMAIL: " $EMAIL
echo "RC_NAMES: " $RC_NAMES
echo "SECRET_NAME: " $SECRET_NAME
echo "CRON frequency: " $CRON_FREQUENCY
# Once a month, fetch and save certs + restart pods.

# The process running under cron needs to know where the to find the kubernetes api
env_vars="PATH=$PATH KUBERNETES_PORT=$KUBERNETES_PORT KUBERNETES_PORT_443_TCP_PORT=$KUBERNETES_PORT_443_TCP_PORT KUBERNETES_SERVICE_PORT=$KUBERNETES_SERVICE_PORT KUBERNETES_SERVICE_HOST=$KUBERNETES_SERVICE_HOST KUBERNETES_PORT_443_TCP_PROTO=$KUBERNETES_PORT_443_TCP_PROTO KUBERNETES_PORT_443_TCP_ADDR=$KUBERNETES_PORT_443_TCP_ADDR KUBERNETES_PORT_443_TCP=$KUBERNETES_PORT_443_TCP"

line="$CRON_FREQUENCY $env_vars SECRET_NAME=$SECRET_NAME RC_NAMES='$RC_NAMES' DOMAINS='$DOMAINS' EMAIL=$EMAIL /bin/bash /letsencrypt/refresh_certs.sh >> /var/log/cron-encrypt.log 2>&1"

if [ "${CRON_FREQUENCY}" != "none" ]; then
  (crontab -u root -l; echo "$line" ) | crontab -u root -
  # Start cron
  echo "Starting cron..."
  cron &
else
  echo $line > /tmp/cron-entry
  echo "Not starting cron since it was specifically not set."
  echo "Just sleeping infinitely..."
fi

sleep infinity
