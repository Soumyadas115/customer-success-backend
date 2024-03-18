FROM ruby:3.2.3

WORKDIR /myapp

COPY . .
RUN gem install bundler
RUN bundle install
COPY .env ./.env
# Expose environment variables from .env file
ENV $(cat .env | grep -v ^# | xargs)
EXPOSE 4000
RUN rails db:create
RUN rails db:migrate
CMD ["rails", "server", "-e", "production", "-b", "0.0.0.0", "-p", "4000"]