pipeline {
    agent any
    tools {
        maven 'M2_HOME'
    }
    stages {

   stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/dorrajem/devops-test-jenkins.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('MVN SONARQUBE') {
            steps {
                sh '''
                    mvn sonar:sonar \
                      -Dsonar.projectKey=devops-test-jenkins \
                      -Dsonar.host.url=http://127.0.0.1:9000 \
                      -Dsonar.login=sqa_3dac205a842fea838bb2bcdab9eac1ae61d1bd41
                '''
            }
        }
    }
    post {
        success {
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
    }
}


