#!env bash

aws ecr get-login --no-include-email | bash
docker push 611630892743.dkr.ecr.ap-northeast-1.amazonaws.com/holidays-api-frontend
