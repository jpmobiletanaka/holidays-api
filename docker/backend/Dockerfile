FROM ruby:2.5.5

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
                            apt-utils build-essential \
                            libpq-dev cron sudo less \
                            chrpath libssl-dev libxft-dev \
                            libfreetype6 libfreetype6-dev \
                            libfontconfig1 libfontconfig1-dev logrotate \
                            mysql-client vim \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash dockeruser
RUN echo "dockeruser ALL=(ALL) NOPASSWD: /usr/sbin/cron" >> /etc/sudoers
USER dockeruser

ENV APP_HOME /home/dockeruser/project
ENV RAILS_ENV staging

WORKDIR $APP_HOME

RUN gem install bundler

ADD --chown=dockeruser ./backend $APP_HOME

RUN bundle check || bundle install --without development test

COPY docker/backend/docker-entrypoint.sh /
COPY docker/backend/ecs-entrypoint.sh /
COPY docker/backend/ecs-entrypoint-migrator.sh /
COPY docker/backend/ecs-entrypoint-seed.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ['/bin/bash']
