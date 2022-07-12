// Copyright (c) 2022 Red Hat, Inc.
// This program and the accompanying materials are made
// available under the terms of the Eclipse Public License 2.0
// which is available at https://www.eclipse.org/legal/epl-2.0/
//
// SPDX-License-Identifier: EPL-2.0
//
// Before buliding, get prerequites:
// * language styles
// * single source external docs
'use strict'

module.exports.register = function () {
    this.on('playbookBuilt', () => {
        var scripts = [
            './tools/checluster_docs_gen.sh',
            './tools/environment_docs_gen.sh'
        ];
        scripts.forEach((script) => {
            const logger = this.getLogger('single-sourcing: ' + script);
            try {
                // Antora must wait for the content.
                require('child_process').execFileSync(script).toString();
                logger.info('Success');
            } catch (e) {
                logger.error('Failed running ' + script)
            }
        })
    })
}
