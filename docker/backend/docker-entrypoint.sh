#!/bin/bash

set -e

sudo cron

export BUNDLE_IGNORE_CONFIG=1

bundle check || bundle install

rm -f tmp/pids/server.pid

RAILS_ENV=development bundle exec rails s -p 3000 -b '0.0.0.0'

exec "$@"
