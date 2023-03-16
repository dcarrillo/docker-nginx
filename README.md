# minimal nginx

![build](https://github.com/dcarrillo/docker-nginx/workflows/CI/badge.svg)

Nginx docker image with a minimal set of modules.

Current modules:

- stream
- http_ssl_module
- http_v2_module
- http_stub_status_module

## Configuration

Edit [conf.env](conf.env)

```bash
NGINX_VERSION=x.xx.x          # Nginx version to build from
DOCKER_IMAGE=dcarrillo/nginx  # Docker image
```

## Build

Build locally:

```bash
./build.sh
```

Build locally and upload the image to a registry (you must be logged in to the registry)

```bash
./build.sh --push
```

Build locally, tag the image as latest and upload it to a registry (you must be logged in to the registry)

```bash
./build.sh --push --latest
```

## Testing

Prerequisites:

- docker
- openssl
- curl

```bash
# build local image
./build.sh

# run tests
./tests/test.sh
```
