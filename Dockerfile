FROM ruby:alpine

ARG INSTALL_PATH
ARG HTTP_PROXY
ARG HTTPS_PROXY

ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY

RUN apk update && \
  apk add build-base \
  curl ruby musl-dev make linux-headers \
  bash less \
  libxml2-dev \
  libxslt-dev \
  busybox \
  curl unzip libexif \
  udev \
  chromium chromium-chromedriver xvfb xorg-server dbus ttf-freefont mesa-dri-swrast \
  wait4ports \
  udev \
  && rm -rf /var/cache/apk/*

# Install build dependencies
 RUN apk add --no-cache --quiet build-base

RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 1.16.2
RUN bundle install
COPY . .
