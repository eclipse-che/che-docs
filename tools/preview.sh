#!/usr/bin/env sh
set -ex

LIVERELOAD=true
export $LIVERELOAD

installandrungulp() { # Install gulp when not present in $PATH
echo "--modules-folder /tmp/node_modules" > /projects/.yarnrc
export HOME=/projects
export NODE_PATH=/tmp/node_modules
yarn add gulp gulp-cli gulp-connect
$NODE_PATH/gulp/bin/gulp.js
}

command -v gulp || installandrungulp && gulp
