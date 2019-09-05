#!/bin/bash

set -e

RAILS_ENV=staging bundle exec rake db:seed

exec "$@"
