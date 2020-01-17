#!/usr/bin/env bash

source ${cur_dir}/functions.sh
source ${cur_dir}/checks.sh

app_env=${APP_ENV}
aws ecs run-task --task-definition holidays-api-${app_env}-migrator --cluster holidays-api-${app_env}-backend
