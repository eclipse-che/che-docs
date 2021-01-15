FROM mrksu/newdoc as newdoc

FROM jdkato/vale as vale

FROM registry.access.redhat.com/ubi8/ubi-minimal

COPY --from=newdoc /usr/local/bin/newdoc /usr/local/bin/newdoc
COPY --from=vale /bin/vale /usr/local/bin/vale

EXPOSE 4000
EXPOSE 35729

LABEL description="Tools to build Eclipse Che documentation: antora, bash, curl, findutils, git, gulp, linkchecker, vale" \
    io.k8s.description="Tools to build Eclipse Che documentation: antora, bash, curl, findutils, git, gulp, jq, linkchecker, newdoc, vale, yq" \
    io.k8s.display-name="Che docs tools" \
    license="Eclipse Public License - v 2.0" \
    MAINTAINERS="Eclipse Che Documentation Team" \
    maintainer="Eclipse Che Documentation Team" \
    name="che-docs" \
    source="https://github.com/eclipse/che-docs/Dockerfile" \
    summary="Tools to build Eclipse Che documentation" \
    URL="quay.io/eclipse/che-docs" \
    vendor="Eclipse Che Documentation Team" \
    version="2021.1"

RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo \
    && microdnf install --refresh -y --nodocs  --best \
    bash \
    curl \
    findutils \
    git-core \
    jq \
    nodejs \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    tar \
    yarn \
    && microdnf clean all \
    && rm -rf /var/lib/dnf \
    && rm -rf /usr/share/doc \
    && pip3 install --no-cache-dir --no-input git+https://github.com/linkchecker/linkchecker.git jinja2-cli yq \
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
    && newdoc --version \
    && vale -v \
    && yq --version

VOLUME /projects
WORKDIR /projects
ENV HOME="/projects" \
    NODE_PATH="/usr/local/share/.config/yarn/global/node_modules"

USER 1001
