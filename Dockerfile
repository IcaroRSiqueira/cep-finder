FROM ruby:3.2.3 as dev
WORKDIR /app

FROM dev as prod
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
COPY . .
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
