FROM jdkato/vale:v2.8.0 as vale

FROM rust:1.49.0-alpine3.12 as newdoc-builder
RUN cargo install newdoc

FROM alpine:3.13

COPY --from=newdoc-builder /usr/local/cargo/bin/newdoc /usr/local/bin/newdoc
COPY --from=vale /bin/vale /usr/local/bin/vale

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
    jq \
    nodejs \
    py3-pip \
    py3-wheel \
    tar \
    yarn \
    yq \
    && pip3 install --no-cache-dir --no-input git+https://github.com/linkchecker/linkchecker.git jinja2-cli \
    && yarnpkg global add --ignore-optional --non-interactive @antora/cli@latest @antora/site-generator-default@latest asciidoctor gulp gulp-connect \
    && rm -rf $(yarnpkg cache dir)/* \
    && rm -rf /tmp/* \
    && antora --version \
    && asciidoctor --version \
    && bash --version \
    && curl --version \
    && git --version \
    && gulp --version \
    && jinja2 --version \
    && jq --version \
    && linkchecker --version \
    && vale -v \
    && yq --version \
    && newdoc --version

VOLUME /projects
WORKDIR /projects
ENV HOME="/projects" \
    NODE_PATH="/usr/local/share/.config/yarn/global/node_modules"

USER 1001
