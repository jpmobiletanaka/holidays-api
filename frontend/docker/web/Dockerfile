FROM node:9

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
                            apt-utils build-essential \
                            cron sudo less \
                            chrpath libssl-dev libxft-dev \
                            libfreetype6 libfreetype6-dev \
                            libfontconfig1 libfontconfig1-dev logrotate \
  && rm -rf /var/lib/apt/lists/*

ENV APP_HOME /home/dockeruser/project

RUN useradd -ms /bin/bash dockeruser
RUN echo "dockeruser ALL=(ALL) NOPASSWD: /usr/sbin/cron" >> /etc/sudoers

WORKDIR $APP_HOME

ADD . $APP_HOME
RUN chown -R dockeruser .

USER dockeruser

RUN echo $API_URL
RUN yarn && yarn build && yarn global add http-server

COPY ../docker/frontend/docker-entrypoint.sh /
COPY ../docker/frontend/ecs-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ['/bin/bash']
