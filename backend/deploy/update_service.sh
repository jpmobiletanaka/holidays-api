#!/usr/bin/env bash

source ${cur_dir}/functions.sh
source ${cur_dir}/checks.sh

app_env=${APP_ENV}
echo "Updating service"
aws ecs update-service --service holidays-api-${app_env}-backend --force-new-deployment --cluster holidays-api-${app_env}-backend
