#!/usr/bin/env bash

set -e

trap _catch_err ERR
trap _cleanup EXIT

LOCAL_DIR=$(dirname "$0")

LOCAL_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
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
    rm -rf "$TMP_DIR"
}

_setup_crypto_stuff()
{
    openssl dhparam -out "$TMP_DIR"/dhparams.pem 512

    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=dcarrillo/CN=localhost" \
        -keyout "$TMP_DIR"/cert.key -out "$TMP_DIR"/cert.pem
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
        printf "Test failed, response %s is not an IP" "$RESPONSE"
        exit 1
    fi
}

_setup_crypto_stuff

docker run --name "${NGINX_VERSION}"_test --rm -p 65521:80 -p 65523:443 \
           -v "$LOCAL_DIR"/nginx.conf:/usr/local/nginx/conf/nginx.conf:ro \
           -v "$LOCAL_DIR"/GeoLite2-Country.mmdb:/tmp/GeoLite2-Country.mmdb:ro \
           -v "$TMP_DIR"/cert.pem:/tmp/cert.pem:ro \
           -v "$TMP_DIR"/cert.key:/tmp/cert.key:ro \
           -v "$TMP_DIR"/dhparams.pem:/tmp/dhparams.pem:ro \
           -d "${DOCKER_IMAGE}":"${NGINX_VERSION}"

printf "\nTesting http request: %s:%s\n" "${DOCKER_IMAGE}" "${NGINX_VERSION}"
STATUS_CODE=$(curl -s -m 5 -o /dev/null -w "%{http_code}" http://localhost:65521/nginx_status)
_check_status_code "$STATUS_CODE"

printf "\nTesting https request: %s:%s\n" "${DOCKER_IMAGE}" "${NGINX_VERSION}"
STATUS_CODE=$(curl -s -m 5 -o /dev/null -w "%{http_code}" --http2 -k https://localhost:65523/)
_check_status_code "$STATUS_CODE"

printf "\nTesting http geoip request: %s:%s\n" "${DOCKER_IMAGE}" "${NGINX_VERSION}"
RESPONSE=$(curl -s -m 5 http://localhost:65521/geoip)
_check_if_is_ip "$RESPONSE"

echo "All tests succeeded !"
