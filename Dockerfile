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
RUN apk add --no-cache --virtual build-dependencies build-base \
    && cd /tmp \
    && bundle install \
    && apk del build-dependencies build-base \
    && apk add --no-cache libstdc++ bash curl python3 \
    && pip3 install newdoc \
    && curl -o /usr/bin/test-adoc.sh https://raw.githubusercontent.com/jhradilek/check-links/master/test-adoc.sh \
    && chmod +x /usr/bin/test-adoc.sh \
    && mkdir /projects \
    && for f in "/projects"; do \
           chgrp -R 0 ${f} && \
           chmod -R g+rwX ${f}; \
       done
CMD tail -f /dev/null
