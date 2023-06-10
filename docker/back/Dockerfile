FROM ruby:2.7.7 AS base

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
                            apt-utils build-essential \
                            libpq-dev cron sudo less \
                            chrpath libssl-dev libxft-dev \
                            libfreetype6 libfreetype6-dev \
                            libfontconfig1 libfontconfig1-dev logrotate \
  && rm -rf /var/lib/apt/lists/*

ENV APP_HOME /home/dockeruser/project

RUN useradd -ms /bin/bash dockeruser
RUN echo "dockeruser ALL=(ALL) NOPASSWD: /usr/sbin/cron" >> /etc/sudoers

WORKDIR $APP_HOME

ADD ./backend $APP_HOME
RUN mkdir -p tmp/cache && chown -R dockeruser .

USER dockeruser

RUN gem install bundler


FROM base AS back-deploy
RUN bundle check || bundle install --without development test
ENTRYPOINT bundle exec whenever -i && \
           sudo cp /var/spool/cron/crontabs/dockeruser /etc/crontab && \
           sudo cron && \
           bundle exec rails s -p 3000 -b '0.0.0.0'


FROM base AS back-dev
RUN export BUNDLE_IGNORE_CONFIG=1 && (bundle check || bundle install)
ENTRYPOINT rm -f tmp/pids/server.pid && \
           bundle exec whenever -i && \
           sudo cp /var/spool/cron/crontabs/dockeruser /etc/crontab && \
           sudo cron && \
           RAILS_ENV=development bundle exec rails s -p 3000 -b '0.0.0.0'
