#
# Copyright (c) 2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

FROM ruby:2.6-alpine3.12
COPY src/main/Gemfile* /tmp/

RUN apk add --no-cache --update libstdc++ bash ca-certificates curl git python3 py3-pip grep perl libxml2-dev xmlstarlet \
    && apk add --no-cache --virtual build-dependencies build-base \
    && cd /tmp \
    && time bundle install --no-cache --frozen \
    && time apk del build-dependencies build-base \
    && rm -rf /root/.bundle/cache \
    && time pip3 install newdoc --upgrade pip --no-cache-dir \
    && newdoc --version \
    && curl -sfLo /usr/bin/test-adoc.sh https://raw.githubusercontent.com/jhradilek/check-links/master/test-adoc.sh \
    && chmod +x /usr/bin/test-adoc.sh \
    && test-adoc.sh -V \
    && curl -sfLo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && curl -sfLo glibc-2.30-r0.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk \
    && apk add --no-cache glibc-2.30-r0.apk \
    && curl -sfLo vale.tar.gz https://github.com/errata-ai/vale/releases/download/v2.0.0/vale_2.0.0_Linux_64-bit.tar.gz \
    && tar xvzf vale.tar.gz -C /usr/bin/ \
    && rm vale.tar.gz \
    && vale -v \
    && mkdir /che-docs \
    && for f in "/che-docs"; do \
           chgrp -R 0 ${f} && \
           chmod -R g+rwX ${f}; \
       done

WORKDIR /che-docs
CMD jekyll clean && jekyll serve --livereload -H 0.0.0.0 --trace
