#
# Copyright (c) 2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

FROM ruby:2.6-alpine
COPY src/main/Gemfile* /tmp/

RUN apk add --no-cache --update libstdc++ bash ca-certificates curl python3 \
    && apk add --no-cache --virtual build-dependencies build-base \
    && cd /tmp \
    && time bundle install --no-cache --frozen \
    && time apk del build-dependencies build-base \
    && time pip3 install newdoc --upgrade pip --no-cache-dir \
    && curl -sfLo /usr/bin/test-adoc.sh https://raw.githubusercontent.com/jhradilek/check-links/master/test-adoc.sh \
    && chmod +x /usr/bin/test-adoc.sh \
    && curl -sfLo vale.sh https://install.goreleaser.com/github.com/ValeLint/vale.sh \
    && bash vale.sh -b /usr/bin \
    && newdoc --version \
    && test-adoc.sh -V \
    && curl -sfLo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && curl -sfLo glibc-2.30-r0.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk \
    && apk add glibc-2.30-r0.apk \
    && vale -v \
    && rm -rf /root/.bundle/cache \
    && mkdir /che-docs \
    && for f in "/che-docs"; do \
           chgrp -R 0 ${f} && \
           chmod -R g+rwX ${f}; \
       done

WORKDIR /che-docs
CMD jekyll clean && jekyll serve --livereload -H 0.0.0.0 --trace
