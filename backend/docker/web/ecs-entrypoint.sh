#!/bin/bash

set -e

sudo cron

bundle exec whenever -i

bundle exec rails s -p 3000 -b '0.0.0.0'

exec "$@"
