FROM nginx:1.10

ENV RAILS_ROOT /home/dockeruser/project
WORKDIR $RAILS_ROOT

COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf

COPY docker/nginx/default.conf /tmp/docker_example.nginx
RUN envsubst '$RAILS_ROOT' < /tmp/docker_example.nginx > /etc/nginx/conf.d/default.conf

RUN mkdir -p /etc/nginx/blacklists
COPY docker/nginx/server.blacklist* /etc/nginx/blacklists/
COPY docker/nginx/web_cmd.sh /tmp/

ENTRYPOINT ["/tmp/web_cmd.sh"]

CMD ["/bin/bash"]
