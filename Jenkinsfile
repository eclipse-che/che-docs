/* groovylint-disable NestedBlockDepth */
pipeline {
  agent {
    kubernetes {
      label 'che-docs-pod'
      yaml '''
apiVersion: v1
metadata:
  labels:
    run: che-docs-pod
  name: che-docs-pod
spec:
  containers:
    - name: jnlp
      volumeMounts:
      - mountPath: /home/jenkins/.ssh
        name: volume-known-hosts
      env:
      - name: "HOME"
        value: "/home/jenkins/agent"
      resources:
        limits:
          memory: "512Mi"
          cpu: "100m"
        requests:
          memory: "512Mi"
          cpu: "100m"
    - name: che-docs
      image: quay.io/eclipse/che-docs
      command:
      - cat
      resources:
        limits:
          memory: "512Mi"
          cpu: "100m"
        requests:
          memory: "512Mi"
          cpu: "100m"
      tty: true
  volumes:
  - configMap:
      name: known-hosts
    name: volume-known-hosts
'''
    }
  }

  environment {
    PROJECT_NAME = 'che'
    PROJECT_BOT_NAME = 'CHE Bot'
    CI = true
  }

  triggers { cron('@daily')
  // The Jenkins Pipeline builds Eclipse Che documentation for the publication
  // to Eclipse website https://www.eclipse.org/che/docs/.
  //
  // It is:
  // * Executing the build from the *Execution branch*.
  // * Using the content from the *Publication branches*.
  // * Pushing the build artifacts to the `che` repository on Eclipse Git server.
  //
  // Eclipse infrastructure then publishes to Eclipse website: https://www.eclipse.org/che/docs/.
  //
  // Execution branch::
  //
  // The build runs on a branch containing at least the `Jenkinsfile` and `antora-playbook.yml` files.
  // It does not need to run at all on other branches.
  // By convention: restrict the build to the `main`, `master` and `publication` branches.
  //
  // Publication branch(es)::
  //
  // The build is using the content from the publication branch(es) defined in the `antora-playbook.yml` file.
  //
  // Triggers::
  //
  // Ideally, run the build when a change in the publication branch happened.
  // But it impossible to implement in current context with the available
  // `pollSCM` or `upstream` triggers https://www.jenkins.io/doc/book/pipeline/syntax/#triggers
  // It would be possible to implement using the `upstream` trigger with a dedicated
  // Jenkins job for the Publication branch, and a dedicated Jenkins job for the Execution branch.
  // Pragmatic solution: run daily with the `cron` trigger.
  //
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    checkoutToSubdirectory('che-docs')
    disableConcurrentBuilds()
    timeout(time: 15, unit: 'MINUTES')
  }

  stages {
    stage('Build che-docs website') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
          branch 'publication'
        }
        beforeAgent true
      }
      steps {
        milestone 21
        container('che-docs') {
          dir('che-docs') {
            sh './tools/build-for-publication.sh'
          }
        }
        milestone 22
      }
      post {
        always {
          archiveArtifacts artifacts: 'che-docs/build/**', fingerprint: true
        }
      }
    }

    stage('Push to Eclipse repository') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
          branch 'publication'
        }
        beforeAgent true
      }
      steps {
        milestone 41
        sh 'ls -la'
        dir('www') {
          sshagent(['git.eclipse.org-bot-ssh']) {
            sh '../che-docs/tools/push-to-eclipse-repository.sh'
          }
        }
        milestone 42
      }
    }
  }
}
