FROM fedora:latest

LABEL description="Tools to build Eclipse Che documentation: antora, bash, curl, findutils, git, gulp, linkchecker, vale"
LABEL io.k8s.description="Tools to build Eclipse Che documentation: antora, bash, curl, findutils, git, gulp, jq, linkchecker, newdoc, vale, yq"
LABEL io.k8s.display name="Che docs tools"
LABEL license="Eclipse Public License - v 2.0"
LABEL MAINTAINERS="Eclipse Che Documentation Team"
LABEL maintainer="Eclipse Che Documentation Team"
LABEL name="che-docs"
LABEL source="https://github.com/eclipse/che-docs/Dockerfile"
LABEL summary="Tools to build Eclipse Che documentation"
LABEL URL="quay.io/eclipse/che-docs"
LABEL vendor="Eclipse Che Documentation Team"
LABEL version="2021.1"

RUN dnf install --refresh -y --nodocs --setopt=install_weak_deps=False --best \
    bash \
    curl \
    dnf-plugins-core \
    findutils \
    git-core \
    jq \
    npm \
    python3-jinja2-cli \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    yarnpkg \
    && dnf copr enable -y mareksu/newdoc-rs \
    && dnf install -y --nodocs --setopt=install_weak_deps=False --best newdoc \
    && dnf clean all \
    && rm -rf /var/lib/dnf \
    && rm -rf /usr/share/doc \
    && pip3 install --no-cache-dir --no-input git+https://github.com/linkchecker/linkchecker.git yq\
    && curl -sfL https://install.goreleaser.com/github.com/ValeLint/vale.sh | sh \
    && mv ./bin/vale /usr/local/bin/vale \
    && yarnpkg global add --ignore-optional --non-interactive @antora/cli@latest @antora/site-generator-default@latest gulp gulp-cli gulp-connect \
    && rm -rf $(yarnpkg cache dir)/* \
    && rm -rf /tmp/* \
    && antora --version \
    && bash --version \
    && curl --version \
    && git --version \
    && gulp --version \
    && jinja2 --version \
    && jq --version \
    && linkchecker --version \
    && newdoc --version \
    && vale -v \
    && yq --version

EXPOSE 4000
EXPOSE 35729

VOLUME /projects
WORKDIR /projects
ENV HOME /projects

USER 1001
