ARG RUBY_VERSION=3.4.7
ARG RAILS_UID=1000
ARG RAILS_GID=1000

FROM ruby:${RUBY_VERSION}-slim AS base

RUN apt-get update -qq && apt-get install -yq --no-install-recommends \
  build-essential \
  curl \
  gnupg2 \
  git \
  libpq-dev \
  libvips \
  libyaml-dev \
  pkg-config \
  postgresql-client \
  # Add other dependencies as needed (e.g., nodejs, yarn, imagemagick)
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app

# Default to prod
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

COPY Gemfile Gemfile.lock ./
RUN bundle install

# Allow access to the global args
ARG RAILS_GID
ARG RAILS_UID
# We create a user both to avoid running as root but also to deal with
# permission issues. Chances are your user will be 1000:1000 anyway on linux,
# but you can change (or provide the arguments) if that is not true. 
#
# If you are not running as this user when you start the app (either in dev or
# prod) you will get into a situation where files will be created with
# unexpected ownership. That is a big issue for the dev container, since it
# volume mounts the entire app and will result in changing the permissions for
# your host system as well.
RUN groupadd --system --gid ${RAILS_GID} rails
RUN useradd rails --uid ${RAILS_UID} --gid ${RAILS_GID} --create-home --shell /bin/bash

####################################
# The development container
####################################
FROM base AS development

ENV RAILS_ENV=development \
    BUNDLE_DEPLOYMENT="false" \
    BUNDLE_WITHOUT=""
RUN bundle install --without production

# Allow access to the global args
ARG RAILS_GID
ARG RAILS_UID
USER ${RAILS_UID}:${RAILS_GID}

EXPOSE 3000
CMD ["./bin/rails", "server", "-b",  "0.0.0.0"]

####################################
# The production containers
# Based on https://docs.docker.com/guides/ruby/containerize/
####################################
FROM base AS production-build

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

# This app is setup as api_only so no asset pipeline to precompile
# RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

FROM base AS production

COPY --from=production-build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=production-build /opt/app /opt/app

RUN chown -R rails:rails db log storage tmp

# Allow access to the global args
ARG RAILS_GID
ARG RAILS_UID
USER ${RAILS_UID}:${RAILS_GID}

ENTRYPOINT ["/opt/app/bin/docker-entrypoint.sh"]
EXPOSE 3000
CMD ["./bin/rails", "server"]