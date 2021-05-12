FROM ruby:3.0

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get update -qq \
  && apt-get install -qq --no-install-recommends \
    nodejs \
  && npm install -g yarn

ENV RAILS_ENV production

ARG user=rails
ARG group=rails
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} && \
    useradd -u ${uid} -g ${group} -s /bin/sh -d /jokerss/ ${user} && \
    mkdir /jokerss && \
    chown ${uid}:${gid} /jokerss && \
    mkdir /data && \
    chown ${uid}:${gid} /data

WORKDIR /jokerss
USER rails

COPY --chown=${uid}:${gid} Gemfile Gemfile.lock package.json yarn.lock /jokerss/

RUN bundle config set --local without 'development test' && \
    bundle config set --local deployment 'true' && \
    bundle install -j8 && \
    yarn

COPY --chown=${uid}:${gid} . .

RUN bundle exec rake assets:precompile

EXPOSE 3000

VOLUME ["/data"]

ENV RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1 \
    DATABASE_URL=sqlite3:/data/db.sqlite3

CMD ["/bin/bash", "docker_start.sh"]
