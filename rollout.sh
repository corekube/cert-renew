#!/bin/bash

# rollout deployment to APP_ENV
REPLACE_DEPLOYMENT=false

while getopts ":re:" opt; do
  case $opt in
    r)
      REPLACE_DEPLOYMENT=true
      ;;
    e)
      APP_ENV=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# repo envvars
source repo-envvars.sh

# k8s envvars
NAMESPACE=$APP_NAME-$APP_ENV

# apply persistent volume claim
PVC_NAME=nfs-pvc
PVC_FILEPATH=k8s/$APP_ENV/pvc/${PVC_NAME}.yaml
kubectl --namespace=$NAMESPACE apply -f $PVC_FILEPATH

# apply nginx configmap
CONFIGMAP_NAME=$APP_NAME-config
CONFIGMAP_FILEPATH=k8s/$APP_ENV/configmaps/${CONFIGMAP_NAME}.yaml
kubectl --namespace=$NAMESPACE apply -f $CONFIGMAP_FILEPATH

# apply || replace deployment
DEPLOYMENT_FILEPATH=k8s/$APP_ENV/deployment/$APP_NAME-deployment.yaml
pushd k8s/$APP_ENV/deployment > /dev/null
./create-$APP_NAME-deployment.yaml.sh
popd > /dev/null

if [ "$REPLACE_DEPLOYMENT" = true ] ; then
  ACTION=replace
else
  ACTION=apply
fi
kubectl --namespace=$NAMESPACE $ACTION -f $DEPLOYMENT_FILEPATH
