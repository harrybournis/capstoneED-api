FROM ruby:2.7.7

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler
RUN bundler update
RUN bundler install

COPY . ./
