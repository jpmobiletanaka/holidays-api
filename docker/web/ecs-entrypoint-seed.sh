#!/bin/bash

set -e

bundle exec rake db:seed

exec "$@"
