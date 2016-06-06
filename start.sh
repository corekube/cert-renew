#!/bin/bash

source /etc/config/cert-renew

# fwd logs to docker log collector
ln -sf /dev/stdout /var/log/cert-renew.log

# soft link /etc/letsencrypt locally from $LETSENCRYPT_DIR volume mount
ln -s $LETSENCRYPT_DIR /etc/letsencrypt

# Once a month, fetch and save certs
minute=$(echo $RANDOM % 60 | bc)
hour=$(echo $RANDOM % 23 | bc)
day=$(echo $RANDOM % 27 + 1 | bc)
month_dow="* *"
random_cron_frequency="$minute $hour $day $month_dow"
CRON_FREQUENCY=${CRON_FREQUENCY:-"$(echo "$random_cron_frequency")"}

echo ""
echo "Configuring cron cron_entry..."
echo "DOMAINS: " $DOMAINS
echo "EMAIL: " $EMAIL
echo "CRON frequency: " "$CRON_FREQUENCY"

# The process running under cron needs to know where the to find the kubernetes api
env_vars="PATH=$PATH KUBERNETES_PORT=$KUBERNETES_PORT KUBERNETES_PORT_443_TCP_PORT=$KUBERNETES_PORT_443_TCP_PORT KUBERNETES_SERVICE_PORT=$KUBERNETES_SERVICE_PORT KUBERNETES_SERVICE_HOST=$KUBERNETES_SERVICE_HOST KUBERNETES_PORT_443_TCP_PROTO=$KUBERNETES_PORT_443_TCP_PROTO KUBERNETES_PORT_443_TCP_ADDR=$KUBERNETES_PORT_443_TCP_ADDR KUBERNETES_PORT_443_TCP=$KUBERNETES_PORT_443_TCP"

# create the entry and the cron-ready entry
entry="DOMAINS='$DOMAINS' EMAIL=$EMAIL /bin/bash /cert-renew/fetch_certs.sh >> /var/log/cert-renew.log 2>&1"
cron_entry="$CRON_FREQUENCY $env_vars $entry"

# enable the entry in cron
echo ""
echo "Enabling cron entry..."
(crontab -u root -l; echo "$cron_entry") | crontab -u root -

echo ""
echo "List cron entries..."
crontab -l

# always run the entry on start
echo ""
echo "Run cron entry..."
eval $entry

# Start cron job
echo ""
echo "Starting cron job..."
cron &

# Sleep inifinitely
echo "Sleeping infinitely to allow cron to run..."
sleep infinity
