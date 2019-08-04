#!/bin/bash

set -e

sudo cron

export NODE_ENV=production

/home/dockeruser/.yarn/bin/http-server ./dist/

exec "$@"
