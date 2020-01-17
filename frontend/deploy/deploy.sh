#!/usr/bin/env bash

cur_dir="$(dirname "$0")"
source ${cur_dir}/functions.sh
source ${cur_dir}/build.sh && \
source ${cur_dir}/push.sh && \
source ${cur_dir}/update_service.sh
