#!/bin/bash

cert_file=`ls -Art /etc/letsencrypt/archive/corekube.com/cert* | tail -n 1`
chain_file=`ls -Art /etc/letsencrypt/archive/corekube.com/chain* | tail -n 1`
fullchain_file=`ls -Art /etc/letsencrypt/archive/corekube.com/fullchain* | tail -n 1`
privkey_file=`ls -Art /etc/letsencrypt/archive/corekube.com/privkey* | tail -n 1`

fullchain=`cat $fullchain_file | base64 -w0`
privkey=`cat $privkey_file | base64 -w0`

cp /srv/k8s/secrets/nginx-tls-template.yaml /srv/k8s/secrets/nginx-tls.yaml
sed -i "s#<FULLCHAIN>#$fullchain#g" /srv/k8s/secrets/nginx-tls.yaml
sed -i "s#<PRIVKEY>#$privkey#g" /srv/k8s/secrets/nginx-tls.yaml

kubectl apply -f /srv/k8s/secrets/nginx-tls.yaml -n nginx-prod

pushd /etc/letsencrypt/live/corekube.com/
ln -sf ../../archive/corekube.com/`basename $cert_file` cert.pem;
ln -sf ../../archive/corekube.com/`basename $chain_file` chain.pem
ln -sf ../../archive/corekube.com/`basename $fullchain_file` fullchain.pem
ln -sf ../../archive/corekube.com/`basename $privkey_file` privkey.pem
popd

kubectl patch deploy/nginx-deployment -n nginx-prod --patch "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"date\":\"`date +'%s'`\"}}}}}"
