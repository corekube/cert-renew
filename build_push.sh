#!/bin/bash

EXPECTEDARGS=3
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <REPO> <IMAGE> <TAG>"
    echo "i.e.: $0 corekube cert-renew 0.0.1"
    exit 0
fi

REPO=$1
IMAGE=$2
TAG=$3

result=`docker build --rm -t $REPO/$IMAGE:$TAG .`
echo "$result"

echo ""
echo "=========================================================="
echo ""

build_status=`echo $result | grep "Successfully built"`

if [ "$build_status" ] ; then
    docker push $REPO/$IMAGE:$TAG 
fi
