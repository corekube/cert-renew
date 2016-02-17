#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# $DOMAINS should contain all domains that this container is responsible for
# renewing. The first one dictates where the cert will live.

# Inside /etc/letsencrypt/live/<domain> we have:
#
# cert.pem  chain.pem  fullchain.pem  privkey.pem
#
# We want to convert fullchain.pem into proxycert
# and privkey.pem into proxykey and then save as a secret!

## setup
source /etc/cert-renew-config-secret/env

if [ -z "$SECRET_NAME" ]; then
    echo "ERROR: Secret name is empty or unset"
    exit 1
fi

LETSENCRYPT_DATA='/etc/letsencrypt'
CERT_DIR="$LETSENCRYPT_DATA/live"

DOMAINS=($DOMAINS)

DOMAIN=${DOMAINS[0]}

FULLCHAIN=$(cat $CERT_DIR/$DOMAIN/fullchain.pem | base64 --wrap=0)
CERT=$(cat $CERT_DIR/$DOMAIN/cert.pem | base64 --wrap=0)
KEY=$(cat $CERT_DIR/$DOMAIN/privkey.pem | base64 --wrap=0)
#DHPARAM=$(openssl dhparam 2048 | base64 --wrap=0)
DHPARAMS=$(cat $LETSENCRYPT_DATA/dhparams.pem | base64 --wrap=0)
CHAIN=$(cat $CERT_DIR/$DOMAIN/chain.pem | base64 --wrap=0)

# perform actions on user-provided $NAMESPACE, or if not given, use this Pod's
# namespace as the default
#MY_NAMESPACE=`kubectl get --all-namespaces po | grep $HOSTNAME | awk '{print $1}'`
#NAMESPACE=${NAMESPACE:-$MY_NAMESPACE}

# look up secret, if successful, we're replacing secret, if not creating it
kubectl get --namespace=$NAMESPACE secrets $SECRET_NAME && ACTION=replace || ACTION=create;

NEW_SECRET_PATH=/tmp/new-secret.yaml

cat << EOF > $NEW_SECRET_PATH
 apiVersion: v1
 kind: Secret
 metadata:
   name: $SECRET_NAME
   namespace: $NAMESPACE
 type: Opaque
 data:
   fullchain.pem: $FULLCHAIN
   cert.pem: $CERT
   privkey.pem: $KEY
   dhparams.pem: $DHPARAMS
   chain.pem: $CHAIN
EOF

kubectl $ACTION -f $NEW_SECRET_PATH
