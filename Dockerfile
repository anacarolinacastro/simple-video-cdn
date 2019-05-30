FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/usr/local/nginx/sbin

ENV NGINX_VERSION 1.13.3
ENV NGINX_TS_VERSION 0.1.1

EXPOSE 8080
EXPOSE 0-65535/udp

RUN mkdir /src /config /logs /data
RUN mkdir /var/media /var/media/hls /var/media/dash

RUN set -x && \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get clean && \
  apt-get install -y --no-install-recommends build-essential \
  wget software-properties-common && \
  apt-get install -y --no-install-recommends libpcre3-dev \
  zlib1g-dev libssl-dev wget

WORKDIR /src
RUN set -x && \
  wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz && \
  wget https://github.com/arut/nginx-ts-module/archive/v${NGINX_TS_VERSION}.tar.gz && \
  tar zxf v${NGINX_TS_VERSION}.tar.gz && \
  rm v${NGINX_TS_VERSION}.tar.gz

WORKDIR /src/nginx-${NGINX_VERSION}
RUN set -x && \
  ./configure --with-http_ssl_module \
  --add-module=/src/nginx-ts-module-${NGINX_TS_VERSION} \
  --with-http_stub_status_module \
  --conf-path=/config/nginx.conf \
  --error-log-path=/logs/error.log \
  --http-log-path=/logs/access.log && \
  make && \
  make install

COPY nginx-origin.conf /config/nginx.conf

WORKDIR /
CMD "nginx"
