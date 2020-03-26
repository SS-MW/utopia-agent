#!/bin/bash

GEMS=(mysql2 sequel jwt)

echo -e '[>] Installing mysql development library...\n\n'
yum -y install mysql-devel

for gem in ${GEMS[*]};
  do
    echo -e "\n\n[>] Installing gem: $gem...\n\n";
    gem install "$gem" --no-doc
  done

echo -e '\n\n[>] Update bundler with gems...\n\n'
gem update bundler
bundle config --local silence_root_warning true

echo -e '\n\n[>] Local ready build...\n'
bundle config set deployment 'false'
bundle install

echo -e '\n\n[>] Deployment ready build...\n'
bundle config set deployment 'true'
bundle install

echo -e '\n\n[>] Copy mysql shared object file to app root build directory...\n'
mkdir lib && cp /usr/lib64/mysql/libmysqlclient.so.18 lib/
