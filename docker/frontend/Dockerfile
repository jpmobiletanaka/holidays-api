FROM node:9

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
                            apt-utils build-essential \
                            cron sudo less \
                            chrpath libssl-dev libxft-dev \
                            libfreetype6 libfreetype6-dev \
                            libfontconfig1 libfontconfig1-dev logrotate \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash dockeruser
RUN echo "dockeruser ALL=(ALL) NOPASSWD: /usr/sbin/cron" >> /etc/sudoers
USER dockeruser

ENV APP_HOME /home/dockeruser/project
ENV NODE_ENV staging

WORKDIR $APP_HOME

ADD --chown=dockeruser ./frontend $APP_HOME

RUN yarn

COPY docker/frontend/docker-entrypoint.sh /
COPY docker/frontend/ecs-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ['/bin/bash']
