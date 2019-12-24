#!/usr/bin/env sh

set -e

. "$(dirname "$0")"/conf.env

while [ $# -gt 0 ]; do
    case $1 in
        --push)
            PUSH=true
            shift
            ;;
        --latest)
            LATEST=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

docker build --build-arg=ARG_NGINX_VERSION="$NGINX_VERSION" \
             --build-arg=ARG_NGX_GEOIP2_VERSION="$NGX_GEOIP2_VERSION" \
             -t "$DOCKER_IMAGE":"$NGINX_VERSION" .

if [ x$PUSH = "xtrue" ]; then
    docker push "$DOCKER_IMAGE":"$NGINX_VERSION"
fi

if [ x$LATEST = "xtrue" ]; then
    docker tag "$DOCKER_IMAGE":"$NGINX_VERSION" "$DOCKER_IMAGE":latest
    [ x$PUSH = "xtrue" ] && docker push "$DOCKER_IMAGE":latest
fi
