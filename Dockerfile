FROM alpine:3.18

ARG ARG_NGINX_VERSION

ENV NGINX_VERSION $ARG_NGINX_VERSION

# hadolint ignore=DL3018,DL3003,SC2086
RUN CONFIG=" \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_stub_status_module \
        --without-http-cache \
        --without-http_autoindex_module \
        --without-http_browser_module \
        --without-http_empty_gif_module \
        --without-http_limit_conn_module \
        --without-http_map_module \
        --without-http_memcached_module \
        --without-http_referer_module \
        --without-http_scgi_module \
        --without-http_split_clients_module \
        --without-http_ssi_module \
        --without-http_upstream_hash_module \
        --without-http_upstream_ip_hash_module \
        --without-http_upstream_keepalive_module \
        --without-http_upstream_least_conn_module \
        --without-http_upstream_zone_module \
        --without-http_userid_module \
        --without-http_uwsgi_module \
        --without-mail_imap_module \
        --without-mail_pop3_module \
        --without-mail_smtp_module \
        --without-select_module \
        --without-stream_access_module \
        --without-stream_limit_conn_module \
        --without-stream_upstream_hash_module \
        --without-stream_upstream_least_conn_module \
        --without-stream_upstream_zone_module \
    " \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        libxslt-dev \
        gd-dev \
    && apk add --no-cache \
        curl \
        pcre \
    \
    # installation
    && curl -sL -o /tmp/nginx.tar.gz http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    && tar -zxC /tmp -f /tmp/nginx.tar.gz \
    && cd /tmp/nginx-$NGINX_VERSION \
    && ./configure $CONFIG \
    && make && make install \
    && mkdir /usr/local/nginx/run \
    \
    # clean up
    && apk del .build-deps \
    && rm -rf /tmp/ng*

STOPSIGNAL SIGTERM

HEALTHCHECK --interval=10s --retries=2 --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
