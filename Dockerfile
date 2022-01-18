# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial implementation
#

FROM docker.io/library/rust:1.51-alpine3.13 as newdoc-builder
RUN apk add --no-cache --update  musl-dev \
    && cargo install newdoc

FROM docker.io/library/golang:1.15-alpine3.13 as htmltest-builder
WORKDIR /htmltest
ARG HTMLTEST_VERSION=0.15.0
RUN wget -qO- https://github.com/wjdp/htmltest/archive/refs/tags/v${HTMLTEST_VERSION}.tar.gz | tar --strip-components=1 -zxvf - \
    &&  export ARCH="$(uname -m)" \
    &&  if [[ ${ARCH} == "x86_64" ]]; \
    then export ARCH="amd64"; \
    elif [[ ${ARCH} == "aarch64" ]]; \
    then export ARCH="arm64"; \
    fi \
    &&  GOOS=linux GOARCH=${ARCH} CGO_ENABLED=0 go build -tags closed -ldflags "-X main.date=`date -u +%Y-%m-%dT%H:%M:%SZ` -X main.version=${HTMLTEST_VERSION}" -o bin/htmltest . \
    &&  /htmltest/bin/htmltest --version

FROM docker.io/library/golang:1.17-alpine3.13 as vale-builder
WORKDIR /vale
ARG VALE_VERSION=2.14.0
RUN wget -qO- https://github.com/errata-ai/vale/archive/v${VALE_VERSION}.tar.gz | tar --strip-components=1 -zxvf - \
    &&  export ARCH="$(uname -m)" \
    &&  if [[ ${ARCH} == "x86_64" ]]; \
    then export ARCH="amd64"; \
    elif [[ ${ARCH} == "aarch64" ]]; \
    then export ARCH="arm64"; \
    fi \
    &&  GOOS=linux GOARCH=${ARCH} CGO_ENABLED=0 go build -tags closed -ldflags "-X main.date=`date -u +%Y-%m-%dT%H:%M:%SZ` -X main.version=${VALE_VERSION}" -o bin/vale ./cmd/vale \
    &&  /vale/bin/vale --version

FROM docker.io/library/alpine:3.15

COPY --from=newdoc-builder /usr/local/cargo/bin/newdoc /usr/local/bin/newdoc
COPY --from=vale-builder /vale/bin/vale /usr/local/bin/vale
COPY --from=htmltest-builder /htmltest/bin/htmltest /usr/local/bin/htmltest

EXPOSE 4000
EXPOSE 35729

LABEL description="Tools to build Eclipse Che documentation." \
    io.k8s.description="Tools to build Eclipse Che documentation." \
    io.k8s.display-name="Che-docs tools" \
    license="Eclipse Public License - v 2.0" \
    MAINTAINERS="Eclipse Che Documentation Team" \
    maintainer="Eclipse Che Documentation Team" \
    name="che-docs" \
    source="https://github.com/eclipse/che-docs/blob/main/Dockerfile" \
    summary="Tools to build Eclipse Che documentation" \
    URL="quay.io/eclipse/che-docs" \
    vendor="Eclipse Che Documentation Team" \
    version="2022.01"

ARG ANTORA_VERSION=3.0.0
RUN apk add --no-cache --update \
    bash \
    curl \
    findutils \
    git \
    grep \
    jq \
    nodejs \
    perl \
    py3-pip \
    py3-wheel \
    shellcheck \
    tar \
    xmlstarlet \
    yarn \
    && pip3 install --no-cache-dir --no-input diagrams jinja2-cli yq \
    && yarnpkg global add --ignore-optional --non-interactive @antora/cli@${ANTORA_VERSION} @antora/site-generator@${ANTORA_VERSION} @antora/site-generator-default@latest @antora/lunr-extension asciidoctor gulp gulp-connect \
    && rm -rf $(yarnpkg cache dir)/* \
    && rm -rf /tmp/* \
    && antora --version \
    && asciidoctor --version \
    && bash --version \
    && curl --version \
    && curl --version \
    && git --version \
    && gulp --version \
    && htmltest --version \
    && jinja2 --version \
    && jq --version \
    && newdoc --version \
    && vale -v \
    && yq --version

VOLUME /projects
WORKDIR /projects
ENV HOME="/projects" \
    NODE_PATH="/usr/local/share/.config/yarn/global/node_modules" \
    USER_NAME=che-docs

USER 1000
