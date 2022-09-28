#!/bin/sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0

umask 002
PROJECT=$1
WORKDIR="$(pwd)"

setvars() {
case "$PROJECT" in
  "che")
    REPO=https://github.com/eclipse-che/che-devfile-registry.git
    DEVFILESDIR=devfiles/;;
  "devspaces")
    REPO=https://github.com/redhat-developer/devspaces.git
    DEVFILESDIR=dependencies/che-devfile-registry/devfiles/;;
  *)
    echo "Use 'che' or 'devspaces' as the only parameter to this script."
    exit 1;;
esac
}

getdata() {
TMPCLONE=$PROJECT-devfiles-shallow

if [ -d $TMPCLONE ]; then
  echo "A working clone of $REPO exists; using."
  cd $TMPCLONE
  git fetch
else
  echo "Need a working clone of $REPO; cloning."
  git clone --depth=1 --filter=blob:none --sparse $REPO $TMPCLONE
  cd $TMPCLONE
  git sparse-checkout set $DEVFILESDIR
fi
}

parsedevfiles() {
cd $DEVFILESDIR

sed '/^displayName:\|^description:\|^tags: \[.*Tech-Preview.*\]/!d;
    s/^displayName: \(.*\)/\1::/;
    s/^description: \(.*\)/\1/;
    s/^tags: \[.*Tech-Preview.*\]/(Technology Preview)/;
    s/\"//g' */meta.yaml | \
    sed '/::$/N;
        s/::\n/:: /;' > "$WORKDIR"/snip_$PROJECT-supported-languages.adoc
}

setvars
getdata
parsedevfiles
