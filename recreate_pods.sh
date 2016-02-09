#!/bin/bash

# Delete all pods that are owned by this RC.
#  - Get the labels that the RC is selecting based on
#  - Delete all the pods with that set of labels.
#  - The RC will then recreate the pods.
#
# Do this so that the secrets can be remounted.

if [ -z "$RC_NAMES" ]; then
    echo "WARNING: RC_NAMES not provided. Secret changes may not be reflected."
    exit
fi

# perform actions on user-provided $NAMESPACE, or if not given, use this Pod's
# namespace as the default
MY_NAMESPACE=`kubectl get --all-namespaces po | grep $HOSTNAME | awk '{print $1}'`
NAMESPACE=${NAMESPACE:-$MY_NAMESPACE}

RC_NAMES=(${RC_NAMES})

for RC_NAME in "${RC_NAMES[@]}"
do
    IMAGE=$(kubectl get --namespace=$NAMESPACE rc $RC_NAME -o=template --template='{{index .spec.template.spec.containers 0 "image"}}')
    kubectl rolling-update --namespace=$NAMESPACE $RC_NAME --image=$IMAGE --update-period=5s
done
