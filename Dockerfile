FROM bitwalker/alpine-elixir:1.8.1 as builder
ENV MIX_ENV test
RUN apk update && \
    apk --no-cache --update upgrade apline-sdk && \
    apk add --no-cache alpine-sdk && \
    rm -rf /var/cache/**/*
COPY . /app
WORKDIR /app
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix format --check-formatted && \
    mix credo && \
    mix test
RUN MIX_ENV=prod mix release

FROM alpine:3.9
ENV CONSUMER_URI=wss://streams.smartcolumbusos.com/socket/websocket
ENV MIX_ENV="prod"
RUN apk update && \
    apk add --no-cache bash openssl && \
    rm -rf /var/cache/**/*
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/micro_service_watchinator/ .
ENV PORT 80
EXPOSE 80
CMD ["bin/micro_service_watchinator", "foreground"]
