#!/usr/bin/env bash

app_env=${APP_ENV}
echo "Updating service"
aws ecs update-service --service holidays-api-${app_env}-frontend --force-new-deployment --cluster holidays-api-${app_env}-frontend
