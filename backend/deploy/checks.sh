#!/usr/bin/env bash

[[ -z "${APP_ENV}" ]] && fail "APP_ENV env variable is not given. Use one of following values: production, staging"
