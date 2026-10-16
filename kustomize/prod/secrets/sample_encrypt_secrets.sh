#!/bin/bash

# This script should help with maintaining secrets. To use:
# 1. cp sample_encrypt_secrets.sh encrypt_secrets.sh (so it won't be commited to github)
# 2. add variables into `--from-literal`; optionally save encrypted secrets to separate files

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PROJECT_NS=$(cat ${SCRIPT_DIR}/../namespace.yaml | grep name | head -1 | sed 's/name: \(\S*\)/\1/')

NAME=secrets
kubectl create secret generic $NAME -n $PROJECT_NS \
        --from-literal=KEY1=secret1 \
        --from-literal=KEY2=secret2 \
        --dry-run=client -o yaml | kubeseal -o yaml > ${SCRIPT_DIR}/${NAME}.yaml
