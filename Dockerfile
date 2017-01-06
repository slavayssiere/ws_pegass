FROM ruby:2.3
MAINTAINER Sebastien Lavayssiere <sebastien.lavayssiere@gmail.com>

RUN apt-get update && \
    apt-get install -y net-tools

# Install gems
ENV APP_HOME /app
ENV HOME /root
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
RUN bundle install

# Upload source
COPY . $APP_HOME

# Start server
EXPOSE 8080
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "8080"]
