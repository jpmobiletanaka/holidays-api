FROM ruby:2.5.5

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
                            apt-utils build-essential \
                            libpq-dev cron sudo less \
                            chrpath libssl-dev libxft-dev \
                            libfreetype6 libfreetype6-dev \
                            libfontconfig1 libfontconfig1-dev logrotate \
                            mariadb-client vim \
  && rm -rf /var/lib/apt/lists/*

ENV APP_HOME /home/dockeruser/project

RUN useradd -ms /bin/bash dockeruser
RUN echo "dockeruser ALL=(ALL) NOPASSWD: /usr/sbin/cron" >> /etc/sudoers

WORKDIR $APP_HOME

ADD . $APP_HOME
RUN mkdir -p tmp/cache && chown -R dockeruser .

USER dockeruser

RUN gem install bundler
RUN bundle check || bundle install --without development test

COPY docker/web/docker-entrypoint.sh /
COPY docker/web/ecs-entrypoint.sh /
COPY docker/web/ecs-entrypoint-migrator.sh /
COPY docker/web/ecs-entrypoint-seed.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ['/bin/bash']
