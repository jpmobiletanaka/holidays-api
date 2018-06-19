#!/bin/bash

set -e

sudo cron

if [ $RAILS_ENV = "production" ] || [ $RAILS_ENV = "staging" ]; then
  bundle install --without development test
else
  bundle install
fi

rm -f tmp/pids/server.pid

bundle exec sidekiq -e $RAILS_ENV -d -L log/sidekiq.log -C config/sidekiq.yml

bundle exec rails s -p 3000 -b '0.0.0.0'

exec "$@"
