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

FROM rust:1.49.0-alpine3.12 as newdoc-builder
RUN cargo install newdoc

FROM golang:1.15.6-alpine3.12 as htmltest-builder
WORKDIR /htmltest
ARG HTMLTEST_VERSION=0.14.0
RUN wget -qO- https://github.com/wjdp/htmltest/archive/refs/tags/v${HTMLTEST_VERSION}.tar.gz | tar --strip-components=1 -zxvf - \
    &&  export ARCH="$(uname -m)" \
    &&  if [[ ${ARCH} == "x86_64" ]]; \
            then export ARCH="amd64"; \
        elif [[ ${ARCH} == "aarch64" ]]; \
            then export ARCH="arm64"; \
        fi \
    &&  GOOS=linux GOARCH=${ARCH} CGO_ENABLED=0 go build -tags closed -ldflags "-X main.date=`date -u +%Y-%m-%dT%H:%M:%SZ` -X main.version=${HTMLTEST_VERSION}" -o bin/htmltest . \
    &&  /htmltest/bin/htmltest --version

FROM golang:1.15.6-alpine3.12 as vale-builder
WORKDIR /vale
ARG VALE_VERSION=2.10.1
RUN wget -qO- https://github.com/errata-ai/vale/archive/v${VALE_VERSION}.tar.gz | tar --strip-components=1 -zxvf - \
    &&  export ARCH="$(uname -m)" \
    &&  if [[ ${ARCH} == "x86_64" ]]; \
            then export ARCH="amd64"; \
        elif [[ ${ARCH} == "aarch64" ]]; \
            then export ARCH="arm64"; \
        fi \
    &&  GOOS=linux GOARCH=${ARCH} CGO_ENABLED=0 go build -tags closed -ldflags "-X main.date=`date -u +%Y-%m-%dT%H:%M:%SZ` -X main.version=${VALE_VERSION}" -o bin/vale ./cmd/vale \
    &&  /vale/bin/vale --version

FROM alpine:3.13

COPY --from=newdoc-builder /usr/local/cargo/bin/newdoc /usr/local/bin/newdoc
COPY --from=vale-builder /vale/bin/vale /usr/local/bin/vale
COPY --from=htmltest-builder /htmltest/bin/htmltest /usr/local/bin/htmltest

EXPOSE 4000
EXPOSE 35729

LABEL description="Tools to build Eclipse Che documentation: antora, asciidoctor.js, bash, curl, findutils, git, gulp, jinja2, jq, linkchecker, newdoc, vale, yq" \
    io.k8s.description="Tools to build Eclipse Che documentation: antora, asciidoctor.js, bash, curl, findutils, git, gulp, jinja2, jq, linkchecker, newdoc, vale, yq" \
    io.k8s.display-name="Che-docs tools" \
    license="Eclipse Public License - v 2.0" \
    MAINTAINERS="Eclipse Che Documentation Team" \
    maintainer="Eclipse Che Documentation Team" \
    name="che-docs" \
    source="https://github.com/eclipse/che-docs/Dockerfile" \
    summary="Tools to build Eclipse Che documentation" \
    URL="quay.io/eclipse/che-docs" \
    vendor="Eclipse Che Documentation Team" \
    version="2021.1"

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
    && yarnpkg global add --ignore-optional --non-interactive @antora/cli@latest @antora/site-generator-default@latest asciidoctor gulp gulp-connect \
    && rm -rf $(yarnpkg cache dir)/* \
    && rm -rf /tmp/* \
    && antora --version \
    && asciidoctor --version \
    && bash --version \
    && curl --version \
    && git --version \
    && gulp --version \
    && htmltest --version \
    && jinja2 --version \
    && jq --version \
    && linkchecker --version \
    && newdoc --version \
    && vale -v \
    && yq --version

VOLUME /projects
WORKDIR /projects
ENV HOME="/projects" \
    NODE_PATH="/usr/local/share/.config/yarn/global/node_modules"

USER 1001
