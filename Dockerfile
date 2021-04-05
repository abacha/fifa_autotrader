FROM ruby:2.7-alpine

RUN apk update && \
  apk add build-base \
  curl ruby musl-dev make linux-headers \
  bash less \
  libxml2-dev \
  libxslt-dev \
  busybox \
  curl unzip libexif \
  tzdata \
  udev \
  chromium chromium-chromedriver xvfb xorg-server dbus ttf-freefont mesa-dri-swrast \
  wait4ports \
  udev \
  sqlite sqlite-dev \
  && rm -rf /var/cache/apk/*

RUN ln -snf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
  echo America/Sao_Paulo > /etc/timezone

RUN mkdir -p app
WORKDIR app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 1.16.2
RUN bundle install
COPY . .
