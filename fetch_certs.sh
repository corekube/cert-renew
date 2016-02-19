#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

## setup
source /etc/cert-renew-config-secret/env

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

LETSENCRYPT_ENDPOINT=${LETSENCRYPT_ENDPOINT:-"https://acme-v01.api.letsencrypt.org/directory"}

/usr/local/bin/letsencrypt certonly \
    --authenticator webroot \
    --server $LETSENCRYPT_ENDPOINT \
    --webroot-path /etc/letsencrypt/webrootauth/ \
    --email $EMAIL \
    --renew-by-default \
    $domain_args \
    --agree-tos
