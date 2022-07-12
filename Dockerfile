# Container definition
#
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

# Build binaries in a temporary container
FROM registry.access.redhat.com/ubi8/go-toolset as builder
USER root

# Build htmltest
WORKDIR /htmltest
ARG HTMLTEST_VERSION=0.16.0
RUN wget -qO- https://github.com/wjdp/htmltest/archive/refs/tags/v${HTMLTEST_VERSION}.tar.gz | tar --strip-components=1 -zxvf - \
    &&  export ARCH="$(uname -m)" \
    &&  if [[ ${ARCH} == "x86_64" ]]; \
    then export ARCH="amd64"; \
    elif [[ ${ARCH} == "aarch64" ]]; \
    then export ARCH="arm64"; \
    fi \
    &&  GOOS=linux GOARCH=${ARCH} CGO_ENABLED=0 go build -tags closed -ldflags "-X main.date=`date -u +%Y-%m-%dT%H:%M:%SZ` -X main.version=${HTMLTEST_VERSION}" -o bin/htmltest . \
    &&  /htmltest/bin/htmltest --version

# Build vale
WORKDIR /vale
ARG VALE_VERSION=2.20.0
RUN wget -qO- https://github.com/errata-ai/vale/archive/v${VALE_VERSION}.tar.gz | tar --strip-components=1 -zxvf - \
    &&  export ARCH="$(uname -m)" \
    &&  if [[ ${ARCH} == "x86_64" ]]; \
    then export ARCH="amd64"; \
    elif [[ ${ARCH} == "aarch64" ]]; \
    then export ARCH="arm64"; \
    fi \
    &&  GOOS=linux GOARCH=${ARCH} CGO_ENABLED=0 go build -tags closed -ldflags "-X main.date=`date -u +%Y-%m-%dT%H:%M:%SZ` -X main.version=${VALE_VERSION}" -o bin/vale ./cmd/vale \
    &&  /vale/bin/vale --version

# Download shellcheck
ARG SHELLCHECK_VERSION=0.8.0
RUN wget -qO- https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.$(uname -m).tar.xz | tar -C /usr/local/bin/ --no-anchored 'shellcheck' --strip=1 -xJf -

# Prepare the container
# FROM quay.io/devfile/universal-developer-image:ubi8-latest # FIXME: Switch to this after fixing https://github.com/devfile/api/issues/873
FROM registry.access.redhat.com/ubi8/nodejs-16
USER root

COPY --from=builder /vale/bin/vale /usr/local/bin/vale
COPY --from=builder /htmltest/bin/htmltest /usr/local/bin/htmltest
COPY --from=builder /usr/local/bin/shellcheck /usr/local/bin/shellcheck

EXPOSE 4000
EXPOSE 35729

LABEL \
    description="Tools to build Eclipse Che documentation." \
    io.k8s.display-name="che-docs" \
    license="Eclipse Public License - v 2.0" \
    maintainer="Red Hat, Inc." \
    name="eclipse/che-docs" \
    source="https://github.com/eclipse-chhe/che-docs/blob/main/Dockerfile" \
    summary="Tools to build Eclipse Che documentation" \
    URL="quay.io/eclipse/che-docs" \
    vendor="Eclipse Che documentation team" \
    version="2022.07"

# Install system packages
RUN set -x \
    && dnf upgrade --assumeyes --quiet \
    && dnf install --assumeyes --quiet \
    bash \
    curl \
    file \
    findutils \
    git-core \
    grep \
    jq \
    nodejs \
    python3-pip \
    python3-wheel \
    tar \
    unzip \
    wget \
    && dnf clean all --quiet

# Install Python pip packages
RUN set -x \
    && pip3 install --no-cache-dir --no-input --quiet \
    diagrams \
    jinja2-cli \
    yq \
    && rm /tmp/* -rfv

# Node.js: using `yarn` rather than `npm` to avoid error:
#   ERR! code ERR_SOCKET_TIMEOUT

# Install Antora and extensions
ARG ANTORA_VERSION=3.0.2
RUN set -x \
    && corepack enable \
    && yarnpkg global add --non-interactive \
    @antora/cli@${ANTORA_VERSION} \
    @antora/lunr-extension \
    @antora/site-generator@${ANTORA_VERSION} \
    asciidoctor \
    asciidoctor-emoji \
    asciidoctor-kroki \
    gulp \
    gulp-cli \
    gulp-connect \
    js-yaml \
    && rm /tmp/* -rfv

# Avoid error: Local gulp not found in /projects
ENV NODE_PATH="/usr/local/share/.config/yarn/global/node_modules"
VOLUME /projects
WORKDIR /projects
USER 1001

RUN set -x \
    && env \
    && antora --version \
    && asciidoctor --version \
    && bash --version \
    && curl --version \
    && git --version \
    && gulp --version \
    && htmltest --version \
    && jinja2 --version \
    && jq --version \
    && pip3 freeze \
    && vale -v \
    && yarnpkg global list \
    && yq --version
