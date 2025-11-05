include conf.env

build:
	docker build --build-arg=ARG_NGINX_VERSION="$(NGINX_VERSION)" \
	             -t "$(DOCKER_IMAGE):$(NGINX_VERSION)" .

build-latest: build
	docker tag "$(DOCKER_IMAGE):$(NGINX_VERSION)" "$(DOCKER_IMAGE):latest"

push-latest: build-latest
	docker push "$(DOCKER_IMAGE):$(NGINX_VERSION)"
	docker push "$(DOCKER_IMAGE):latest"

.PHONY: tests
tests:
	./tests/test.sh
