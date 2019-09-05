#!/bin/bash

set -e

RAILS_ENV=staging bundle exec rake db:migrate

exec "$@"
