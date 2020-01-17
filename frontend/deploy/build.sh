#!/usr/bin/env bash

cur_dir="$(dirname "$0")"
docker_dir="${cur_dir}/../docker"
target_dir="${cur_dir}/../"

source ${cur_dir}/functions.sh

docker build -f ${docker_dir}/web/Dockerfile -t 611630892743.dkr.ecr.ap-northeast-1.amazonaws.com/holidays-api-frontend ${target_dir}
