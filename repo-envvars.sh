#!/bin/bash

# default values are intended for local usage rather than ci/cd env
export BUILD_COMMIT=${WERCKER_GIT_COMMIT-`git rev-parse HEAD`}
export BUILD_COMMIT=${BUILD_COMMIT:0:7}
export BUILD_BRANCH=${WERCKER_GIT_BRANCH-`git rev-parse --abbrev-ref HEAD`}
export APP_NAME=${WERCKER_APPLICATION_NAME-`basename $(git rev-parse --show-toplevel)`}
export OWNER_NAME=${WERCKER_APPLICATION_OWNER_NAME-`whoami`}
export OWNER_NAME=`echo $OWNER_NAME | awk '{print tolower($0)}'`
export DOCKER_REPO=${DOCKER_REPO-corekube/$APP_NAME}
export IMAGE_TAG="$OWNER_NAME-$BUILD_BRANCH-${BUILD_COMMIT:0:7}"
