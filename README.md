# minimal nginx

![build](https://github.com/dcarrillo/docker-nginx/workflows/CI/badge.svg)

Nginx docker image with a minimal set of modules.

Current modules:

- [geoip2](https://github.com/leev/ngx_http_geoip2_module)
- stream
- http_ssl_module
- http_v2_module
- http_stub_status_module

## Configuration

Edit [conf.env](conf.env)

```bash
NGINX_VERSION=x.xx.x          # Nginx version to build from
NGX_GEOIP2_VERSION=x.x        # Nginx geoip2 version to build from
DOCKER_IMAGE=dcarrillo/nginx  # Docker image
```

## Build

Build locally:

```bash
./build.sh
```

Build locally and upload to a registry (you must be logged in to the registry)

```bash
./build.sh --push
```

Build locally, tag image as latest and upload to a registry (you must be logged in to the registry)

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

## Who is using this image

[ifconfig.es](https://ifconfig.es) is a web service that displays information about your
connection, including IP address, geolocation and request http headers. You can easily get
your public ip address using curl, wget and other command-line http clients.
