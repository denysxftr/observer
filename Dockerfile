FROM ruby:2.3.0

RUN mkdir /observer
WORKDIR /observer
ADD . /observer
RUN bundle install
RUN gem install foreman
RUN cp /observer/mongoid.yml.example /observer/mongoid.yml
