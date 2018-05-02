FROM amazonlinux:latest

RUN yum update -y && yum install -y ruby && gem install bundler

ENV APP_ROOT /usr/src/app
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

ADD Gemfile* $APP_ROOT/
RUN bundle install

ADD . $APP_ROOT

# CMD [ "ruby", "process_image.rb" ]
