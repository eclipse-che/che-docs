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
          cpu: "200m"
        requests:
          memory: "512Mi"
          cpu: "200m"
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
    triggers { 
        pollSCM('@hourly') 
        }
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        checkoutToSubdirectory('che-docs')
        disableConcurrentBuilds(abortPrevious: true)
        timeout(time: 30, unit: 'MINUTES')
        }
    stages {
        stage('Push to Eclipse repository') {
            when {
                anyOf {
                    branch 'publication'
                    }
                beforeAgent true
                }
            steps {
                milestone 1
                sh 'ls -la'
                dir('www') {
                sshagent(['git.eclipse.org-bot-ssh']) {
                    sh '../che-docs/push-to-eclipse-repository.sh'
                    }
                }
                milestone 2
            }
        }
    }
}