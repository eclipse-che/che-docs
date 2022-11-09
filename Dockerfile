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
# Container to build and test Eclipse Che documentation

# Require podman to run ccutil
FROM quay.io/podman/stable:latest

# Require superuser privileges to install packages
USER root

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
    version="2022.11"

# Install system packages
RUN set -x \
    && dnf install --assumeyes --quiet dnf-plugins-core \
    && dnf copr enable --assumeyes --quiet mczernek/vale \
    && dnf install --assumeyes --quiet \
    ShellCheck \
    bash \
    curl \
    file \
    findutils \
    git-core \
    graphviz \
    grep \
    htmltest \
    jq \
    nodejs \
    python3-pip \
    rsync \
    rubygem-bundler \
    shyaml \
    tar \
    tox \
    tree \
    unzip \
    vale \
    wget \
    which \
    && dnf clean all --quiet \
    && dot -v \
    && node --version \
    && ruby --version \
    && vale --version

# Install Python packages
RUN set -x \
    && pip3 install --no-cache-dir --no-input --quiet \
    diagrams \
    yq \
    && yq --version

# Install Ruby packages (requires Ruby 2.7)
RUN set -x \
    && gem install asciidoctor-pdf \
    && which asciidoctor-pdf \
    && asciidoctor --version \
    && asciidoctor-pdf --version

# WORKDIR is a Node.js prerequisite
WORKDIR /tmp
# Avoid error: Local gulp not found in /projects
ENV NODE_PATH="/usr/local/lib/node_modules/"
# Install Node.js packages, one by one to avoid timeouts
RUN set -x \
    && npm install --no-save --global @antora/cli \
    && npm install --no-save --global @antora/collector-extension \
    && npm install --no-save --global @antora/lunr-extension \
    && npm install --no-save --global @antora/pdf-extension \
    && npm install --no-save --global @antora/site-generator \
    && npm install --no-save --global asciidoctor-emoji \
    && npm install --no-save --global asciidoctor-kroki \
    && npm install --no-save --global gulp gulp-cli gulp-connect \
    && npm install --no-save --global js-yaml \
    && which antora \
    && antora --version \
    && rm /tmp/* --recursive --force

VOLUME /projects
WORKDIR /projects

# Pulling an image requires to be the podman user
#USER podman
# Pull the ccutil image (doesn't work when building on Quay)
#RUN podman pull quay.io/ivanhorvath/ccutil:amazing

# Test that binaries are available
RUN set -x \
    && antora --version \
    && asciidoctor --version \
    && asciidoctor-pdf --version \
    && bash --version \
    && curl --version \
    && git --version \
    && gulp --version \
    && htmltest --version \
    && jq --version \
    && pip3 freeze \
    && vale --version \
    && yq --version
