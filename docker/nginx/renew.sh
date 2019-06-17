#!/bin/sh

/home/dockeruser/project/ssl/dehydrated -c
/usr/sbin/nginx -t && /usr/sbin/nginx -s reload
