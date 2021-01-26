FROM alpine:latest

LABEL openconnect.documentation="https://www.infradead.org/openconnect/index.html"
RUN apk update && apk add ca-certificates tzdata \
  && apk add iptables
ENV OPENCONNECT_CONFIG=/etc/openconnect/openconnect.conf
RUN set -xe \
    && mkdir -p $(dirname $OPENCONNECT_CONFIG) \
    && touch $OPENCONNECT_CONFIG \
    && echo
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUn echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk upgrade && apk add dumb-init openconnect openssl iputils net-tools curl dante-server
RUN addgroup openconnect && adduser openconnect -D -H -G openconnect
USER openconnect
ENTRYPOINT ["/bin/ash", "-c", "set -e && /openconnect/entrypoint.sh"]
STOPSIGNAL SIGINT

ENV OPENCONNECT_TIMESTAMP=true
ENV OPENCONNECT_VERBOSE=false
ENV OPENCONNECT_NON-INTER=true

COPY ./resource /openconnect
