#!/bin/bash

# $DOMAINS should contain all domains that this container is responsible for
# renewing. The first one dictates where the cert will live.

# Inside /etc/letsencrypt/live/<domain> we have:
#
# cert.pem  chain.pem  fullchain.pem  privkey.pem
#
# We want to convert fullchain.pem into proxycert
# and privkey.pem into proxykey and then save as a secret!

if [ -z "$SECRET_NAME" ]; then
    echo "ERROR: Secret name is empty or unset"
    exit 1
fi

CERT_DIR='/etc/letsencrypt/live'

DOMAINS=($DOMAINS)

DOMAIN=${DOMAINS[0]}

FULLCHAIN=$(cat $CERT_DIR/$DOMAIN/fullchain.pem | base64 --wrap=0)
CERT=$(cat $CERT_DIR/$DOMAIN/cert | base64 --wrap=0)
KEY=$(cat $CERT_DIR/$DOMAIN/privkey.pem | base64 --wrap=0)
#DHPARAM=$(openssl dhparam 2048 | base64 --wrap=0)
DHPARAM=$CERT_DIR/dhparams.pem
CHAIN=$CERT_DIR/chain.pem

kubectl get secrets $SECRET_NAME && ACTION=replace || ACTION=create;

cat << EOF | kubectl $ACTION -f -
 apiVersion: v1
 kind: Secret
 metadata:
   name: "$SECRET_NAME"
   namespace: "$NAMESPACE"
 type: Opaque
 data:
   fullchain.pem: "$FULLCHAIN"
   cert.pem: "$CERT"
   privkey.pem: "$KEY"
   dhparams.pem: "$DH"
   chain.pem: "$CHAIN"
EOF
