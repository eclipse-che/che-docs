'use strict'

const connect = require('gulp-connect')
const util = require('util');
const exec = util.promisify(require('child_process').exec);
const fs = require('fs')
const generator = require('@antora/site-generator-default')
const { reload: livereload } = process.env.LIVERELOAD === 'true' ? require('gulp-connect') : {}
const { parallel, series, src, watch } = require('gulp')
const yaml = require('js-yaml')

const playbookFilename = 'antora-playbook-for-development.yml'
const playbook = yaml.load(fs.readFileSync(playbookFilename, 'utf8'))
const outputDir = (playbook.output || {}).dir || './build/site'
const serverConfig = { name: 'Preview Site', livereload, host: '0.0.0.0', port: 4000, root: outputDir }
const antoraArgs = ['--playbook', playbookFilename]
const watchPatterns = playbook.content.sources.filter((source) => !source.url.includes(':')).reduce((accum, source) => {
  accum.push(`./antora.yml`)
  accum.push(`./modules/**/*`)
  return accum
}, [])

function generate(done) {
  generator(antoraArgs, process.env)
    .then(() => done())
    .catch((err) => {
      console.log(err)
      done()
    })
}

async function serve(done) {
  connect.server(serverConfig, function () {
    this.server.on('close', done)
    watch(watchPatterns, series(generate, testlang, testhtml, detect_unused_content, antora_to_plain_asciidoc))
    if (livereload) watch(this.root).on('change', (filepath) => src(filepath, { read: false }).pipe(livereload()))
  })
}

async function checluster_docs_gen() {
  // Report script errors but don't make gulp fail.
  try {
    const { stdout, stderr } = await exec('tools/checluster_docs_gen.sh')
    console.log(stdout);
    console.error(stderr);
  }
  catch (error) {
    console.log(error.stdout);
    console.log(error.stderr);
    return;
  }
}

async function environment_docs_gen() {
  // Report script errors but don't make gulp fail.
  try {
    const { stdout, stderr } = await exec('tools/environment_docs_gen.sh')
    console.log(stdout, stderr);
  }
  catch (error) {
    console.log(error.stdout, error.stderr);
    return;
  }
}

async function testhtml() {
  // Report links errors but don't make gulp fail.
  try {
    const { stdout, stderr } = await exec('htmltest')
    console.log(stdout, stderr);
  }
  catch (error) {
    console.log(error.stdout, error.stderr);
    return;
  }
}

async function testlang() {
  // Report language errors but don't make gulp fail.
  try {
    const { stdout, stderr } = await exec('./tools/validate_language_changes.sh')
    console.log(stdout, stderr);
  }
  catch (error) {
    console.log(error.stdout, error.stderr);
    return;
  }
}

async function detect_unused_content() {
  // Report unused images but don't make gulp fail.
  try {
    const { stdout, stderr } = await exec('./tools/detect-unused-content.sh')
    console.log(stdout, stderr);
  }
  catch (error) {
    console.log(error.stdout, error.stderr);
    return;
  }
}

async function antora_to_plain_asciidoc() {
  // Report unused images but don't make gulp fail.
  try {
    const { stdout, stderr } = await exec('./tools/antora-to-plain-asciidoc.sh')
    console.log(stdout, stderr);
  }
  catch (error) {
    console.log(error.stdout, error.stderr);
    return;
  }
}

exports.default = series(
  parallel(checluster_docs_gen, environment_docs_gen),
  generate,
  serve,
  parallel(testlang, testhtml, detect_unused_content, antora_to_plain_asciidoc)
);
