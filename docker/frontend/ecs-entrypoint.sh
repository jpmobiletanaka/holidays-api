#!/bin/bash

set -e

sudo cron

yarn check || yarn

yarn run dev

exec "$@"
