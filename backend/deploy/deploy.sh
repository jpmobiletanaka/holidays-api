#!/usr/bin/env bash

cur_dir="$(dirname "$0")"
source ${cur_dir}/functions.sh
parse_args "${@}"
CLUSTER_NAME=${CLUSTER_NAME:="${APP_NAME}-${APP_ENV}"}
printf "Deploying ${CLUSTER_NAME} "
printf "for ${APP_ENV}\n"
source ${cur_dir}/build.sh
source ${cur_dir}/push.sh

if [[ $? == 0 ]]; then
  read -p "Migration needed (y/n): " migration_needed
  if [[ "${migration_needed}" == "y" ]]; then
    echo "Migration needed.."
    source ${cur_dir}/migrate.sh && \
    source ${cur_dir}/update_service.sh
  else
     echo "Migration not needed.."
     source ${cur_dir}/update_service.sh
  fi
fi
