#!/usr/bin/env sh
echo "--modules-folder /tmp/node_modules" > /projects/.yarnrc
export HOME=/projects
export NODE_PATH=/tmp/node_modules
yarn add gulp gulp-cli gulp-connect
LIVERELOAD=true $NODE_PATH/gulp/bin/gulp.js
