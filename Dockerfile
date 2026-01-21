ARG RUBY_VERSION=3.4.7
FROM ruby:${RUBY_VERSION}

WORKDIR /opt/app
RUN apt-get update -qq && apt-get install -y postgresql-client

COPY Gemfile Gemfile.lock ./
RUN bundle install

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]