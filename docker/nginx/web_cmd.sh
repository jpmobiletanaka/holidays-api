#!/bin/bash

# initialize the letsencrypt.sh environment
setup_letsencrypt() {

  # create the directory that will serve ACME challenges
  mkdir -p .well-known/acme-challenge
  chmod -R 755 .well-known

  # See https://github.com/lukas2511/letsencrypt.sh/blob/master/docs/domains_txt.md
  echo "$SERVER_NAME" > domains.txt
  echo "$SERVER_NAME_2" >> domains.txt

  # See https://github.com/lukas2511/letsencrypt.sh/blob/master/docs/staging.md
  #echo "CA=\"https://acme-staging.api.letsencrypt.org/directory\"" > config
  #echo "CA_TERMS=\"https://acme-staging.api.letsencrypt.org/terms\"" >> config

  # See https://github.com/lukas2511/letsencrypt.sh/blob/master/docs/wellknown.md
  echo "WELLKNOWN=\"$SSL_ROOT/.well-known/acme-challenge\"" >> config

  # fetch stable version of letsencrypt.sh
  curl "https://raw.githubusercontent.com/lukas2511/dehydrated/master/dehydrated" > dehydrated
  chmod 755 dehydrated
}

# creates self-signed SSL files
# these files are used in development and get production up and running so letsencrypt.sh can do its work
create_pems() {
  echo 'create pems'
  mkdir $SSL_CERT_HOME/$1
  cd $SSL_CERT_HOME/$1
  openssl req -x509 -nodes -days 730 -newkey rsa:1024 -keyout privkey.pem -out fullchain.pem -subj "/C=JP/ST=Tokyo/L=Tokyo/O=Metroengines/OU=Sales/CN=$1"
  chmod 600 *.pem
}

create_dhparam() {
  echo 'create dhparam'
  cd $SSL_CERT_HOME/live
  openssl dhparam -out dhparam.pem 2048
  chmod 600 dhparam.pem
}

# if we have not already done so initialize Docker volume to hold SSL files
#if [ ! -d "$SSL_CERT_HOME/live" ]; then
#  mkdir -p $SSL_CERT_HOME/live
#  chmod 755 $SSL_ROOT
#  chmod -R 700 $SSL_ROOT/certs
#  create_pems $SERVER_NAME
#  create_pems $SERVER_NAME_2
#  create_dhparam
#  cd $SSL_ROOT
#  setup_letsencrypt
#fi

# if we are configured to run SSL with a real certificate authority run letsencrypt.sh to retrieve/renew SSL certs
if [ "$CA_SSL" = "true" ]; then

  # Nginx must be running for challenges to proceed
  # run in daemon mode so our script can continue
  nginx

  # retrieve/renew SSL certs
  cd $SSL_ROOT
  ./dehydrated --cron

  #write out current crontab
  crontab -l > mycron
  #echo new cron into cron file
  echo "@daily /tmp/renew.sh" >> mycron
  #install new cron file
  crontab mycron
  rm mycron

  # pull Nginx out of daemon mode
  nginx -s stop
fi

mkdir -p log
# start Nginx in foreground so Docker container doesn't exit
nginx -g "daemon off;"
