pipeline {
 
  agent {
    kubernetes {
      label 'che-docs-pod'
      yaml """
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
    - name: che-docs
      image: quay.io/eclipse/che-docs
      command:
      - cat
      tty: true
    - name: antora
      image: docker.io/antora/antora
      command:
      - cat
      tty: true
    - name: vale
      image: docker.io/jdkato/vale
      command:
      - cat
      tty: true
  volumes:
  - configMap:
      name: known-hosts
    name: volume-known-hosts
"""
    }
  }
 
  environment {
    PROJECT_NAME = "che"
    PROJECT_BOT_NAME = "CHE Bot"
  }
 
  triggers { pollSCM('H/10 * * * *') 
 
 }
 
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
    checkoutToSubdirectory('che-docs')
  }
 
  stages {
    stage('Checkout www repo') {
      when {
        branch 'master'
      }
      steps {
       container('jnlp') {
        dir('www') {
            sshagent(['git.eclipse.org-bot-ssh']) {
                sh '''
                    GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone ssh://genie.${PROJECT_NAME}@git.eclipse.org:29418/www.eclipse.org/${PROJECT_NAME}.git .
                    git checkout master
                '''
            }
        }
       }
      }
    }
    stage('Build website (master) with Che Docs') {
      steps {
        container('che-docs') {
            dir('che-docs') {
                sh './tools/enviromnent_docs_gen.sh &&  cd src/main && jekyll build --config _config.yml,_config-web.yml'
            }
        }
      }
    }

    stage('Push to $env.BRANCH_NAME branch') {
      when {
        branch 'master'
      }
      steps {
        sh 'ls -la'
        dir('www') {
            sshagent(['git.eclipse.org-bot-ssh']) {
                sh '''
                cd "${WEBSITE}"
                rm -rf docs/ && mkdir -p docs/images/
                cp -Rvf ../che-docs/src/main/images/* docs/images/
                cp -Rvf ../che-docs/src/main/_site/* docs/
                git add -A
                if ! git diff --cached --exit-code; then
                  echo "Changes have been detected, publishing to repo 'www.eclipse.org/${PROJECT_NAME}'"
                  git config --global user.email "${PROJECT_NAME}-bot@eclipse.org"
                  git config --global user.name "${PROJECT_BOT_NAME}"
                  export DOC_COMMIT_MSG=$(git log --oneline --format=%B -n 1 HEAD | tail -1)
                  git commit -m "[docs] ${DOC_COMMIT_MSG}"
                  git log --graph --abbrev-commit --date=relative -n 5
                  git push origin HEAD:${BRANCH_NAME}
                else
                  echo "No change have been detected since last build, nothing to publish"
                fi
                '''
            }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'build/**', fingerprint: true
    }
  }

}


