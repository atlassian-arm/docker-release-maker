#!/bin/sh

# This script will invoke Snyk for an image, optionally, any functional tests if present.
#
#   Usage: <path-to>/integration_test.sh <IMAGE-ID-OR-HASH>  ['true' if a release image] ['true' if tests should be run]
#
# The release image flag defaults to false, the testing flag to true.

set -e

if [ $# -eq 0 ]; then
    echo "No docker image supplied. Syntax: integration_test.sh <image tag or hash> ['true' if a release image]"
    exit 1
fi
IMAGE=$1
IS_RELEASE=${2:-false}
RUN_FUNCTESTS=${3:-true}

echo "######## Security Scan ########"
SEV_THRESHOLD=${SEV_THRESHOLD:-high}

if [ x"${SNYK_TOKEN}" = 'x' ]; then
    echo 'Security scan is interrupted because Snyk authentication token (SNYK_TOKEN) is not defined!'
    exit 1
fi

echo "Authenticating with Snyk..."
snyk auth -d $SNYK_TOKEN

echo "Performing security scan for image $IMAGE (threshold=${SEV_THRESHOLD})"
snyk container test -d $IMAGE --severity-threshold=$SEV_THRESHOLD

# If we're releasing the image we should enable monitoring:
if [ $IS_RELEASE = true ]; then
    echo "Enabling Snyk monitoring for image $IMAGE"
    snyk container monitor -d $IMAGE --severity-threshold=$SEV_THRESHOLD
else
    echo "Publish flag is not set, skipping Snyk monitoring"
fi


echo "######## Integration Testing ########"
if [ $RUN_FUNCTESTS = true ]; then
    FUNCTEST_SCRIPT=${FUNCTEST_SCRIPT:-'./func-tests/run-functests'}
    if [ -x $FUNCTEST_SCRIPT ]; then
        echo "Invoking ${FUNCTEST_SCRIPT} ${IMAGE}"
        ${FUNCTEST_SCRIPT} $IMAGE
    else
        echo "Testing script ${FUNCTEST_SCRIPT} doesn't exist or is not executable; skipping."
    fi
else
    echo "Functest flag not set, skipping"
fi

exit 0
