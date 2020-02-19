# vim: set ft=dockerfile :

#
# Alpine Linux Branch
#

ARG ALPINE_BRANCH=latest

#
# Build Container
#

FROM alpine:${ALPINE_BRANCH:-latest} AS build
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

RUN apk --no-cache --update add alpine-sdk dumb-init
RUN mkdir -p /builder/aports
RUN mkdir -p /builder/packages
RUN mkdir -p /var/cache/distfiles
RUN echo '%abuild ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

#
# Builder Container
#

FROM scratch AS builder
LABEL maintainer "Takumi Takahashi <takumiiinn@gmail.com>"

COPY --from=build / /
ENTRYPOINT ["dumb-init", "--", "entrypoint.sh"]
CMD ["abuild"]
VOLUME ["/builder/aports", "/builder/packages", "/var/cache/distfiles"]
