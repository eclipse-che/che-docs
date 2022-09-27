'use strict'

const antora = require('@antora/site-generator')
const connect = require('gulp-connect')
const gulp = require('gulp')

function generate(done) {
    antora(['--playbook', 'antora-playbook-for-development.yml'], process.env)
        .then(() => done())
        .catch((err) => {
            console.log(err)
            done()
    })
    connect.reload()
}

async function serve(done) {
    connect.server({
        name: 'Preview Site',
        livereload: true,
        host: '0.0.0.0',
        port: 4000,
        root: './build/site'
    });
    gulp.watch(['./modules/**/*'], generate)
}

exports.default = gulp.series(
    generate,
    serve,
);
