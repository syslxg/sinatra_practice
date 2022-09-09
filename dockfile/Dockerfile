FROM ubuntu:20.04
RUN ln -snf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ruby ruby-dev ruby-bundler nginx \
    build-essential bison openssl libreadline-dev \
    curl git zlib1g zlib1g-dev libssl-dev libyaml-dev \
    libxml2-dev autoconf libc6-dev libncurses-dev automake libtool libpq-dev

COPY nginx.conf /etc/nginx/sites-available/default 
RUN useradd demo
RUN cd /var && \
    git clone https://github.com/syslxg/sinatra_practice.git &&\
    cd sinatra_practice && \
    bundle