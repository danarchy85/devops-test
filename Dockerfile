FROM ruby:2.7

WORKDIR /opt/devops-test

COPY . .

RUN bundle install

CMD ["bundle", "exec", "foreman", "start"]
