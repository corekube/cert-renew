#!/bin/bash

EMAIL=${EMAIL}
DOMAINS=(${DOMAINS})

if [ -z "$DOMAINS" ]; then
    echo "ERROR: Domain list is empty or unset"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo "ERROR: Email is empty string or unset"
    exit 1
fi

domain_args=""
for i in "${DOMAINS[@]}"
do
    domain_args="$domain_args -d $i"
    # do whatever on $i
done

/usr/local/bin/letsencrypt certonly \
    --authenticator webroot \
    --webroot-path /etc/letsencrypt/webrootauth/ \
    --email $EMAIL \
    --renew-by-default \
    $domain_args \
    --agree-tos
