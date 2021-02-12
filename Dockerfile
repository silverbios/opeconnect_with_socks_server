FROM alpine:latest

LABEL openconnect.documentation="https://www.infradead.org/openconnect/index.html"
ENV OPENCONNECT_CONFIG=/etc/openconnect/openconnect.conf
RUN set -xe \
    && mkdir -p $(dirname $OPENCONNECT_CONFIG) \
    && touch $OPENCONNECT_CONFIG \
    && echo
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk upgrade && apk add ca-certificates tzdata iptables iproute2 dumb-init openconnect openssl iputils net-tools curl dante-server xmlstarlet
RUN addgroup openconnect && adduser openconnect -D -H -G openconnect
USER openconnect
ENTRYPOINT ["/bin/ash", "-c", "set -e && /openconnect/entrypoint.sh"]
STOPSIGNAL SIGINT

ENV OPENCONNECT_TIMESTAMP=true
ENV OPENCONNECT_VERBOSE=false
ENV OPENCONNECT_NON-INTER=true

COPY ./resource /openconnect
