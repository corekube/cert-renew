#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source /etc/config/cert-renew

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
done

/certbot-auto --no-self-upgrade certonly \
    --authenticator webroot \
    --server $LETSENCRYPT_ENDPOINT \
    --webroot-path /etc/letsencrypt/webrootauth/ \
    --email $EMAIL \
    --renew-by-default \
    $domain_args \
    --agree-tos
