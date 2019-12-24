#!/usr/bin/env bash

set -e

if [ x"$DEBUG" = xtrue ]; then
    set -x
fi

trap _catch_err ERR
trap _cleanup EXIT

ALPINE_VERSION="alpine:3.11"
LOCAL_DIR="$(cd "$(dirname "$0")" ; pwd -P)"
. "$LOCAL_DIR"/../conf.env

TMP_DIR=$(mktemp -d)

_catch_err()
{
    echo "Test FAILED"
}

_cleanup()
{
    echo "Cleaning up..."
    docker rm -f "${NGINX_VERSION}"_test > /dev/null 2>&1
    docker rm -f "${NGINX_VERSION}"_requester > /dev/null 2>&1
    rm -rf "$TMP_DIR"
}

_setup_crypto_stuff()
{
    echo "Generating SSL files..."
    openssl dhparam -out "$TMP_DIR"/dhparams.pem 512 > /dev/null 2>&1
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=dcarrillo/CN=localhost" \
        -keyout "$TMP_DIR"/cert.key -out "$TMP_DIR"/cert.pem > /dev/null 2>&1
}

_check_status_code()
{
    if [ "$1" != 200 ]; then
        printf "Test failed, status code %s is not 200\n" "$STATUS_CODE"
        exit 1
    else
        echo "Test succeeded"
    fi
}

_check_if_is_ip()
{
    if echo "$1" | grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" > /dev/null; then
        echo "Test succeeded"
    else
        printf "Response: %s\nTest failed, response is not an IP\n" "$RESPONSE"
        exit 1
    fi
}

_setup_crypto_stuff

echo "Running container to be tested..."
docker run --name "${NGINX_VERSION}"_test --rm \
           -v "$LOCAL_DIR"/nginx.conf:/usr/local/nginx/conf/nginx.conf:ro \
           -v "$LOCAL_DIR"/GeoLite2-Country.mmdb:/tmp/GeoLite2-Country.mmdb:ro \
           -v "$TMP_DIR"/cert.pem:/tmp/cert.pem:ro \
           -v "$TMP_DIR"/cert.key:/tmp/cert.key:ro \
           -v "$TMP_DIR"/dhparams.pem:/tmp/dhparams.pem:ro \
           -d "${DOCKER_IMAGE}":"${NGINX_VERSION}" > /dev/null

echo "Preparing requester container..."
docker run --name "${NGINX_VERSION}"_requester --rm --link "${NGINX_VERSION}"_test \
           -ti -d $ALPINE_VERSION sh > /dev/null
exec_docker="docker exec -ti ${NGINX_VERSION}_requester"
$exec_docker apk add curl > /dev/null

for request in http://${NGINX_VERSION}_test/nginx_status https://${NGINX_VERSION}_test/nginx_status; do
    printf "\nRequesting %s\n" "$request"
    STATUS_CODE=$($exec_docker curl -s -k -m 5 -o /dev/null -w "%{http_code}" "$request")
    _check_status_code "$STATUS_CODE"
done

request="http://${NGINX_VERSION}_test/ip"
printf "\nRequesting %s\n" "$request"
RESPONSE=$($exec_docker curl -s -m 5 "$request" | tr -d '\r')
_check_if_is_ip "$RESPONSE"

echo "All tests succeeded !"
