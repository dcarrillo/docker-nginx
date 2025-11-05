#!/usr/bin/env bash

set -e

# shellcheck disable=SC2039
trap catch_err ERR
trap cleanup EXIT

TMP_DIR=$(mkdir /tmp/nginx-ssl && echo /tmp/nginx-ssl)
LOCAL_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

catch_err()
{
    echo "Test FAILED"
}

cleanup()
{
    echo "Cleaning up..."
    docker compose down
    rm -rf "$TMP_DIR"
    popd > /dev/null
}

setup_crypto()
{
    echo "Generating SSL files..."
    openssl dhparam -out "$TMP_DIR"/dhparams.pem 2048 > /dev/null 2>&1
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=dcarrillo/CN=localhost" \
        -keyout "$TMP_DIR"/cert.key -out "$TMP_DIR"/cert.pem > /dev/null 2>&1
}

check_status_code()
{
    if [ "$1" != 200 ]; then
        printf "Test failed, status code %s is not 200\n" "$STATUS_CODE"
        exit 1
    else
        echo "Test succeeded"
    fi
}

setup_crypto
pushd "$LOCAL_DIR" > /dev/null
ln -s ../conf.env .env &>/dev/null || true
docker compose up --build --detach

requests="
http://localhost/nginx_status
https://localhost/nginx_status
"
for request in $requests; do
    printf "\nRequesting %s\n" "$request"
    STATUS_CODE=$(curl -s -k -m 5 -o /dev/null -w "%{http_code}" "$request")
    check_status_code "$STATUS_CODE"
done

echo "All tests succeeded !"
