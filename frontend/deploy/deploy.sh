#!env bash

sh ./frontend/deploy/build.sh && sh ./frontend/deploy/push.sh && sh ./frontend/deploy/update_service.sh
