#!/bin/bash -xe

# introducing sleep so network interfaces and routes can get ready before fetching software
sleep 10
apt-get update
apt-get install -y \
  ruby ruby-dev ruby-bundler \
  build-essential bison openssl libreadline-dev \
  curl git zlib1g zlib1g-dev libssl-dev libyaml-dev \
  libxml2-dev autoconf libc6-dev libncurses-dev automake libtool libpq-dev

cd /var
git clone https://github.com/syslxg/sinatra_practice.git
cd sinatra_practice
bundle