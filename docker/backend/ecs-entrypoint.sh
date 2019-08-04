#!/bin/bash

set -e

sudo cron

RAILS_ENV=staging bundle exec rails s -p 3000 -b '0.0.0.0'

exec "$@"
