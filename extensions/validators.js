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
        var validators = [
            'htmltest',
            './tools/antora-to-plain-asciidoc.sh',
            './tools/detect-unused-content.sh',
            './tools/validate_language_changes.sh'
        ];
        validators.forEach((script) => {
            const logger = this.getLogger('validate: ' + script)
            require('child_process').execFile(script, (error, stdout, stderr) => {
                if (error) {
                    logger.error(stdout + stderr);
                    return;
                }
                logger.info(stdout);
            })
        })
    })
}
