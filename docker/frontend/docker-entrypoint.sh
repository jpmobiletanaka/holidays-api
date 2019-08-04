#!/bin/bash

set -e

sudo cron

yarn check || yarn

NODE_ENV=development yarn run dev

exec "$@"
