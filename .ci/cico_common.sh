#!/bin/bash
# Copyright (c) 2017 Red Hat, Inc.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html

# Just a script to get and build eclipse-che locally
# please send PRs to github.com/kbsingh/build-run-che

# update machine, get required deps in place
# this script assumes its being run on CentOS Linux 7/x86_64

load_jenkins_vars() {
    set +x
    eval "$(./env-toolkit load -f jenkins-env.json \
                              CHE_BOT_GITHUB_TOKEN \
                              CHE_MAVEN_SETTINGS \
                              CHE_OSS_SONATYPE_GPG_KEY \
                              CHE_OSS_SONATYPE_PASSPHRASE)"
}

load_mvn_settings_gpg_key() {
    set -x
    mkdir $HOME/.m2
    set +x
    #prepare settings.xml for maven and sonatype (central maven repository)
    echo $CHE_MAVEN_SETTINGS | base64 -d > $HOME/.m2/settings.xml 
    #load GPG key for sign artifacts
    echo $CHE_OSS_SONATYPE_GPG_KEY | base64 -d > $HOME/.m2/gpg.key
    set -x
    gpg --import $HOME/.m2/gpg.key
}

install_deps(){
    set +x
    yum -y update
    yum -y install centos-release-scl-rh java-1.8.0-openjdk-devel git 
    yum -y install rh-maven33
}

build_and_deploy_artifacts() {
    set -x
    scl enable rh-maven33 'mvn clean install -U'
    if [ $? -eq 0 ]; then
        echo 'Build Success!'
        echo 'Going to deploy artifacts'
        scl enable rh-maven33 "mvn clean deploy -Pcodenvy-release -DcreateChecksum=true  -Dgpg.passphrase=$CHE_OSS_SONATYPE_PASSPHRASE"
        exit 0
    else
        echo 'Build Failed!'
        exit 1
    fi
}

releaseProject() {
    #test 4
    CUR_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
    TAG = $(echo $CUR_VERSION | cut -d'-' -f1) #cut SNAPSHOT form the version name
    echo -e "\x1B[92m############### Release: $TAG\x1B[0m"
    scl enable rh-maven33 "mvn release:prepare release:perform -B -Dresume=false -Dtag=$TAG -DreleaseVersion=$TAG '-Darguments=-DskipTests=true -Dskip-validate-sources -Dgpg.passphrase=$CHE_OSS_SONATYPE_PASSPHRASE -Darchetype.test.skip=true -Dversion.animal-sniffer.enforcer-rule=1.16'"
}