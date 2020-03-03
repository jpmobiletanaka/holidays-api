#!env bash

app_env=${APP_ENV}
aws ecs run-task --task-definition holidays-api-${app_env}-migrator --cluster holidays-api-${app_env}-backend
