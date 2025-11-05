# minimal nginx

![build](https://github.com/dcarrillo/docker-nginx/workflows/CI/badge.svg)

Nginx docker image with a minimal set of modules. The image is based on the official Nginx image and it is built from source.

Current modules:

- stream
- http_ssl_module
- http_v2_module
- http_stub_status_module

## Configuration

Edit [conf.env](conf.env)

```bash
NGINX_VERSION=x.xx.x          # Nginx version to build from
DOCKER_IMAGE=dcarrillo/nginx  # Docker image target
```

## Build

Build locally:

```bash
make build
```

Push image (it includes latest tag):

```bash
make push-latest
```

## Testing

Prerequisites:

- docker
- openssl
- curl

```bash
make tests
```
