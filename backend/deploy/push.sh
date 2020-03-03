#!env bash

cur_dir="$(dirname "$0")"
source ${cur_dir}/functions.sh

aws ecr get-login --no-include-email | bash
docker push 611630892743.dkr.ecr.ap-northeast-1.amazonaws.com/holidays-api-backend
