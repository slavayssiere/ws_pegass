FROM ruby:2.5-alpine
MAINTAINER Sebastien Lavayssiere <sebastien.lavayssiere@gmail.com>

RUN apk add --no-cache net-tools g++ make

# Install gems
ENV APP_HOME /app
ENV HOME /root
ENV REDIS_HOST redis-slave
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
RUN bundle install

# Upload source
COPY . $APP_HOME

# Start server
EXPOSE 8080
CMD ["rackup", "--host", "0.0.0.0", "-p", "8080"]
