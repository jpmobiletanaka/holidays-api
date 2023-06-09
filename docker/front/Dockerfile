FROM node:15.9.0 AS base

ENV APP_HOME /home/dockeruser/project

RUN useradd -ms /bin/bash dockeruser

WORKDIR $APP_HOME
ADD ./frontend $APP_HOME
RUN chown -R dockeruser .

USER dockeruser

RUN yarn && yarn build && yarn global add http-server


FROM base AS front-deploy
ENTRYPOINT export NODE_ENV=production && \
           /home/dockeruser/.yarn/bin/http-server ./dist/


FROM base AS front-dev
ENTRYPOINT (yarn check || yarn) && \
           NODE_ENV=development yarn run dev
