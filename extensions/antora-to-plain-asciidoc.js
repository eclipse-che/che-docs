// Copyright (c) 2022 Red Hat, Inc.
// This program and the accompanying materials are made
// available under the terms of the Eclipse Public License 2.0
// which is available at https://www.eclipse.org/legal/epl-2.0/
//
// SPDX-License-Identifier: EPL-2.0
//

// Validate the docs asynchronously.
'use strict'
module.exports.register = function () {
    this.on('sitePublished', () => {
        require('child_process').execFile('./tools/antora-to-plain-asciidoc.sh', (error, stdout, stderr) => {
            if (error) {
                console.log(stdout + stderr);
                return;
            }
            console.log(stdout);
        })
    })
}
