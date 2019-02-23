FROM ruby:2.6

RUN apt-get update && apt-get install -y git default-jdk

RUN curl --create-dirs -o /usr/local/bin/embulk -L "https://dl.embulk.org/embulk-latest.jar"
RUN chmod +x /usr/local/bin/embulk

RUN useradd --create-home --user-group --uid 1000 app && mkdir /app /vendor && chown app:app /app /vendor

USER app

WORKDIR /app
