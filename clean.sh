#!/bin/bash

# clean out k8s components

EXPECTEDARGS=1
if [ $# -lt $EXPECTEDARGS ]; then
  echo "Usage: $0 <APP_ENV>"
  exit 1
fi

APP_ENV=$1

# repo envvars
source repo-envvars.sh

# k8s envvars
NAMESPACE=$APP_NAME-$APP_ENV

# clear everything
kubectl --namespace=$NAMESPACE delete --ignore-not-found deployment $APP_NAME-deployment
kubectl --namespace=$NAMESPACE delete --ignore-not-found configmap $APP_NAME-config
kubectl --namespace=$NAMESPACE delete --ignore-not-found pvc $APP_NAME-nfs-pvc
