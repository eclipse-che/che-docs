#
# Copyright (c) 2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
FROM ruby:2.5-alpine
COPY src/main/Gemfile* /tmp/
RUN apk add --no-cache --virtual build-dependencies build-base libstdc++ \
    && cd /tmp && bundle install \
    && apk del build-dependencies build-base \
    && mkdir /projects \
    && for f in "/projects"; do \
           chgrp -R 0 ${f} && \
           chmod -R g+rwX ${f}; \
       done
CMD tail -f /dev/null
