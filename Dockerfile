# change this to respective ruby and bundle version
FROM ruby:3.0.3-slim

# Setting env up
ENV RAILS_ENV='production'
ENV RACK_ENV='production'
ENV RAILS_SERVE_STATIC_FILES='yes'
ENV APP_HOME='/app'
ENV BUNDLER_VERSION=2.2.32

# install required packages
# RUN apk update && apk add postgresql-dev build-base tzdata
RUN apt-get update && apt-get install -y build-essential libpq-dev libgmp-dev imagemagick fonts-roboto

# Set working directory
WORKDIR ${APP_HOME}

# install bundler
# update here
RUN gem install bundler:${BUNDLER_VERSION}
RUN bundle config set without 'development test'

# Adding gems
COPY Gemfile ${APP_HOME}
COPY Gemfile.lock ${APP_HOME}

# install gems
RUN bundle install

# copy files
COPY . ${APP_HOME}

# added rubocop test to catch syntax error 
# and prevent success build
RUN bundle exec rubocop -l

# vulnerability check
RUN bundle exec brakeman -w3

# expose port
EXPOSE 3000

# run puma
CMD ["bundle", "exec", "puma", "-e", "production"]