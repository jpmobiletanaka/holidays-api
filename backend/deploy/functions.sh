#!/usr/bin/env bash

function fail {
  local err=$?
  set +o xtrace
  local code="${2:-1}"
  printf 'ERROR: %s\n' "$1" >&2
  # Print out the stack trace described by $function_stack
  if [ ${#FUNCNAME[@]} -gt 2 ]
  then
    echo "Call tree:"
    for ((i=1;i<${#FUNCNAME[@]}-1;i++))
    do
      echo " $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]} ${FUNCNAME[$i]}(...)"
    done
  fi
  echo "Exiting with status ${code}"
  exit "${code}"
}

function parse_args () {
  while [ $# -gt 0 ]; do
    case "$1" in
      -c=*|--cluster=*)
        CLUSTER_NAME="${1#*=}"
        ;;
      -a=*|--app-name=*)
        APP_NAME="${1#*=}"
        ;;
      -e=*|--app-env=*)
        APP_ENV="${1#*=}"
        ;;
      *)
        printf "***************************\n"
        printf "* Error: Invalid argument.*\n"
        printf "***************************\n"
        fail "Exiting", 1
    esac
    shift
  done
}
